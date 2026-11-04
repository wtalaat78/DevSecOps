[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    [switch]$IncludeTrivy,
    [switch]$IncludeCheckov,
    [switch]$IncludeSbom,
    [switch]$SkipEcosystemAudit
)
$ErrorActionPreference = 'Continue'
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outDir = Join-Path $project 'security\reports'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$log = Join-Path $outDir "devsecops-$stamp.log"
$results = New-Object System.Collections.Generic.List[object]

# Secret and PII Redaction Filter
function Redact-SensitiveData([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    $sanitized = $Text
    # Redact Private Keys
    $sanitized = [regex]::Replace($sanitized, '(?s)-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----.*?-----END (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----', '[REDACTED_PRIVATE_KEY]')
    # Redact AWS Access Keys
    $sanitized = [regex]::Replace($sanitized, '(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}', '$1[REDACTED_AWS_KEY]')
    # Redact GitHub / GitLab / Slack Tokens
    $sanitized = [regex]::Replace($sanitized, '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,255}', '$1_[REDACTED_GITHUB_TOKEN]')
    $sanitized = [regex]::Replace($sanitized, 'glpat-[A-Za-z0-9_\-]{20,}', 'glpat-[REDACTED_GITLAB_TOKEN]')
    $sanitized = [regex]::Replace($sanitized, 'xox[baprs]-[0-9a-zA-Z]{10,48}', 'xox-[REDACTED_SLACK_TOKEN]')
    # Redact JWTs
    $sanitized = [regex]::Replace($sanitized, 'eyJ[a-zA-Z0-9_\-]{10,}\.eyJ[a-zA-Z0-9_\-]{10,}\.[a-zA-Z0-9_\-]+', '[REDACTED_JWT]')
    # Redact connection strings with passwords: scheme://user:pass@host
    $sanitized = [regex]::Replace($sanitized, '([a-zA-Z][a-zA-Z0-9+.-]*://)([^:\s@]+):([^@\s]+)@', '$1$2:[REDACTED_PASSWORD]@')
    return $sanitized
}

function Run-Tool {
    param(
        [string]$Name,
        [string]$Exe,
        [string[]]$Args,
        [int[]]$FindingExitCodes = @(1),
        [string]$ReportArtifact = $null
    )
    $cmd = Get-Command $Exe -ErrorAction SilentlyContinue
    if (-not $cmd) {
        $results.Add([pscustomobject]@{
            tool = $Name
            status = 'NOT RUN'
            reason = "Executable '$Exe' not found on PATH"
            exitCode = $null
            command = $Exe
            reportFile = $null
        })
        return
    }

    $cmdDisplay = "$($cmd.Name) $($Args -join ' ')"
    "### $Name`n$cmdDisplay" | Out-File -FilePath $log -Append -Encoding UTF8

    $global:LASTEXITCODE = 0
    try {
        # Execute tool safely
        $targetExe = if ($cmd.Path) { $cmd.Path } else { $cmd.Name }
        $rawOutput = & $targetExe @Args 2>&1
        $code = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
    } catch {
        $rawOutput = $_.Exception.Message
        $code = 999
    }

    # Redact secrets before logging
    $cleanedOutput = Redact-SensitiveData ($rawOutput | Out-String)
    $cleanedOutput | Out-File -FilePath $log -Append -Encoding UTF8

    # Determine status based on explicit tool exit codes
    if ($code -eq 0) {
        $status = 'PASS'
        $reason = 'Clean run, no vulnerabilities reported by tool.'
    } elseif ($code -in $FindingExitCodes) {
        $status = 'FINDINGS_FOUND'
        $reason = "Security findings identified (Exit code: $code). Review report."
    } else {
        $status = 'ERROR_OR_CRASH'
        $reason = "Tool exited with unexpected return code ($code). Check log for errors."
    }

    $results.Add([pscustomobject]@{
        tool = $Name
        status = $status
        reason = $reason
        exitCode = $code
        command = $cmdDisplay
        reportFile = $ReportArtifact
    })
}

Write-Host "DevSecOps Maximum Scan: Starting scan on $project..." -ForegroundColor Cyan

# 1. Gitleaks Secrets Scan
$gitleaksJson = Join-Path $outDir "gitleaks-$stamp.json"
Run-Tool -Name 'Gitleaks Secrets Scan' -Exe 'gitleaks' `
    -Args @('detect', '--source', $project, '--no-git', '--redact', '--report-format', 'json', '--report-path', $gitleaksJson) `
    -FindingExitCodes @(1) -ReportArtifact $gitleaksJson

# 2. Semgrep SAST Scan
$semgrepConfig = Join-Path (Split-Path -Parent $PSScriptRoot) 'config\semgrep.yml'
$semgrepArgs = if (Test-Path $semgrepConfig) {
    @('scan', '--config', $semgrepConfig, '--metrics=off', '--json', '--output', (Join-Path $outDir "semgrep-$stamp.json"), $project)
} else {
    @('scan', '--config', 'auto', '--metrics=off', $project)
}
Run-Tool -Name 'Semgrep SAST' -Exe 'semgrep' -Args $semgrepArgs -FindingExitCodes @(1) -ReportArtifact (Join-Path $outDir "semgrep-$stamp.json")

# 3. OSV-Scanner Dependency Scan
$osvJson = Join-Path $outDir "osv-scanner-$stamp.json"
Run-Tool -Name 'OSV-Scanner Dependencies' -Exe 'osv-scanner' `
    -Args @('scan', 'source', '-r', '--json', '--output', $osvJson, $project) `
    -FindingExitCodes @(1) -ReportArtifact $osvJson

# 4. Multi-Stack Native Ecosystem Audits (Zero-Install when runtimes exist)
if (-not $SkipEcosystemAudit) {
    # Node.js
    if (Test-Path (Join-Path $project 'package.json')) {
        $npmCmd = Get-Command 'npm' -ErrorAction SilentlyContinue
        if ($npmCmd) {
            Run-Tool -Name 'Node.js npm audit' -Exe 'npm' -Args @('audit', '--prefix', $project) -FindingExitCodes @(1)
        }
    }
    # Python
    $pyManifest = @('requirements.txt', 'pyproject.toml', 'Pipfile.lock') | Where-Object { Test-Path (Join-Path $project $_) }
    if ($pyManifest) {
        $pipAuditCmd = Get-Command 'pip-audit' -ErrorAction SilentlyContinue
        if ($pipAuditCmd) {
            Run-Tool -Name 'Python pip-audit' -Exe 'pip-audit' -Args @('-r', (Join-Path $project 'requirements.txt')) -FindingExitCodes @(1)
        }
    }
    # Rust
    if (Test-Path (Join-Path $project 'Cargo.lock')) {
        $cargoAuditCmd = Get-Command 'cargo-audit' -ErrorAction SilentlyContinue
        if ($cargoAuditCmd) {
            Run-Tool -Name 'Rust Cargo Audit' -Exe 'cargo-audit' -Args @('audit') -FindingExitCodes @(1)
        }
    }
    # Go
    if (Test-Path (Join-Path $project 'go.mod')) {
        $govulnCmd = Get-Command 'govulncheck' -ErrorAction SilentlyContinue
        if ($govulnCmd) {
            Run-Tool -Name 'Go Vulnerability Check' -Exe 'govulncheck' -Args @('./...') -FindingExitCodes @(1)
        }
    }
    # .NET
    $dotnetProjects = Get-ChildItem -Path $project -Filter '*.csproj' -Recurse -ErrorAction SilentlyContinue
    if ($dotnetProjects) {
        $dotnetCmd = Get-Command 'dotnet' -ErrorAction SilentlyContinue
        if ($dotnetCmd) {
            Run-Tool -Name '.NET Package Vulnerability Check' -Exe 'dotnet' -Args @('list', $project, 'package', '--vulnerable') -FindingExitCodes @(1)
        }
    }
}

# 5. Optional Trivy Filesystem Scan (with explicit exit code and severity)
if ($IncludeTrivy) {
    $trivyJson = Join-Path $outDir "trivy-$stamp.json"
    Run-Tool -Name 'Trivy Security Scan' -Exe 'trivy' `
        -Args @('fs', '--scanners', 'vuln,misconfig,secret', '--skip-dirs', '.git', '--severity', 'HIGH,CRITICAL', '--exit-code', '1', '--format', 'json', '--output', $trivyJson, $project) `
        -FindingExitCodes @(1) -ReportArtifact $trivyJson
}

# 6. Optional Checkov IaC Scan
if ($IncludeCheckov) {
    $checkovJson = Join-Path $outDir "checkov-$stamp.json"
    Run-Tool -Name 'Checkov IaC Scan' -Exe 'checkov' `
        -Args @('-d', $project, '--quiet', '--output', 'json', '--output-file-path', $outDir) `
        -FindingExitCodes @(1)
}

# 7. Optional Syft SBOM Generation
if ($IncludeSbom) {
    $sbomDir = Join-Path $project 'security\sbom'
    New-Item -ItemType Directory -Force -Path $sbomDir | Out-Null
    $sbomFile = Join-Path $sbomDir "sbom-$stamp.cdx.json"
    Run-Tool -Name 'Syft SBOM Generation' -Exe 'syft' `
        -Args @("dir:$project", '-o', "cyclonedx-json=$sbomFile") `
        -FindingExitCodes @(1) -ReportArtifact $sbomFile
}

# Generate Consolidated Summary
$summary = [pscustomobject]@{
    scanTimestamp = (Get-Date).ToString('o')
    projectRoot = $project
    scope = 'Local filesystem & dependency analysis; non-disruptive'
    results = $results
    logFile = $log
    disclaimer = 'Execution of automated security tools does not guarantee zero vulnerabilities. Manual threat modeling and code review remain required.'
}

$jsonSummaryPath = Join-Path $outDir "devsecops-$stamp.json"
$summary | ConvertTo-Json -Depth 8 | Out-File -FilePath $jsonSummaryPath -Encoding UTF8

$mdSummaryPath = Join-Path $outDir "devsecops-$stamp.md"
$mdLines = @(
    "# DevSecOps Scan Summary",
    "",
    "- **Generated:** $($summary.scanTimestamp)",
    "- **Project Target:** $project",
    "- **Scope:** $($summary.scope)",
    "- **Log File:** $log",
    "",
    "## Scanner Execution Results",
    "",
    "| Tool / Check | Status | Exit Code | Details / Reason |",
    "|---|:---:|:---:|---|"
)

foreach ($r in $results) {
    $badge = switch ($r.status) {
        'PASS' { '[PASS]' }
        'FINDINGS_FOUND' { '[FINDINGS FOUND]' }
        'ERROR_OR_CRASH' { '[TOOL ERROR]' }
        default { '[NOT RUN]' }
    }
    $mdLines += "| $($r.tool) | **$badge** | $($r.exitCode) | $($r.reason) |"
}

$mdLines += @(
    "",
    "## Action Items & Next Steps",
    "- **Investigate Findings:** Open the detailed tool reports in the reports directory for any check marked `FINDINGS FOUND`.",
    "- **Secret Leaks:** If Gitleaks reported findings, coordinate immediate credential rotation and verify git history.",
    "- **Tool Errors:** For checks marked `TOOL ERROR`, inspect the log file to diagnose configuration or syntax issues.",
    "- **Verification:** Never mark security tasks as complete without verifying fixes with a clean re-scan."
)
$mdLines | Out-File -FilePath $mdSummaryPath -Encoding UTF8

Write-Host "`nScan completed successfully." -ForegroundColor Green
Write-Host "  Markdown Summary : $mdSummaryPath" -ForegroundColor Yellow
Write-Host "  JSON Summary     : $jsonSummaryPath" -ForegroundColor Yellow
Write-Host "  Redacted Log     : $log" -ForegroundColor Yellow
