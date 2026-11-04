[CmdletBinding()]
param(
    [ValidateSet('Antigravity','Claude','Both')]
    [string]$Platform = 'Both',
    [switch]$Force,
    [switch]$NoGlobalInstructions
)
$ErrorActionPreference = 'Stop'
$PackageRoot = Split-Path -Parent $PSScriptRoot
$SkillSource = Join-Path $PackageRoot 'skill'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Install-Skill([string]$Destination) {
    if (Test-Path $Destination) {
        if (-not $Force) { throw "Destination exists: $Destination. Re-run with -Force to back it up and replace." }
        $backup = "$Destination.backup-$Stamp"
        Move-Item -LiteralPath $Destination -Destination $backup
        Write-Host "Backed up existing skill to $backup" -ForegroundColor DarkGray
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Path (Join-Path $SkillSource '*') -Destination $Destination -Recurse -Force
    # Copy references and templates into the skill directory for self-contained progressive disclosure
    $refDest = Join-Path $Destination 'references'
    New-Item -ItemType Directory -Force -Path $refDest | Out-Null
    Copy-Item -Path (Join-Path $PackageRoot 'references\*') -Destination $refDest -Recurse -Force

    $tplDest = Join-Path $Destination 'templates'
    New-Item -ItemType Directory -Force -Path $tplDest | Out-Null
    Copy-Item -Path (Join-Path $PackageRoot 'templates\*') -Destination $tplDest -Recurse -Force

    Write-Host "Installed skill: $Destination" -ForegroundColor Green
}

function Add-ManagedBlock([string]$Path, [string]$BlockContent, [string]$Start, [string]$End) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $existing = if (Test-Path $Path) { Get-Content -LiteralPath $Path -Raw } else { '' }
    $begin = [regex]::Escape($Start); $finish = [regex]::Escape($End)
    $pattern = "(?s)$begin.*?$finish"
    $managed = "$Start`r`n$BlockContent`r`n$End"
    if ($existing -match $pattern) {
        $existing = [regex]::Replace($existing, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $managed.TrimEnd() })
    } else {
        $prefix = if ([string]::IsNullOrWhiteSpace($existing)) { '' } else { $existing.TrimEnd() + "`r`n`r`n" }
        $existing = $prefix + $managed.TrimEnd() + "`r`n"
    }
    Set-Content -LiteralPath $Path -Value $existing -Encoding UTF8
}

$start = '<!-- DEVSECOPS-MAXIMUM:START -->'
$end = '<!-- DEVSECOPS-MAXIMUM:END -->'

if ($Platform -in @('Antigravity','Both')) {
    $dest = Join-Path $HOME '.gemini\config\skills\devsecops-maximum'
    Install-Skill $dest

    if (-not $NoGlobalInstructions) {
        $ruleSrc = Join-Path $PackageRoot 'platform\antigravity\global-rule.md'
        $ruleContent = Get-Content -LiteralPath $ruleSrc -Raw

        # 1. Primary Antigravity global rules directory: ~/.gemini/config/rules/devsecops.md
        $rulesDir = Join-Path $HOME '.gemini\config\rules'
        New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null
        $ruleTarget = Join-Path $rulesDir 'devsecops.md'
        Set-Content -LiteralPath $ruleTarget -Value $ruleContent -Encoding UTF8
        Write-Host "Installed Antigravity rule file: $ruleTarget" -ForegroundColor Green

        # 2. Global AGENTS.md managed block: ~/.gemini/config/AGENTS.md and ~/.gemini/AGENTS.md
        $primaryAgentsMd = Join-Path $HOME '.gemini\config\AGENTS.md'
        Add-ManagedBlock -Path $primaryAgentsMd -BlockContent $ruleContent -Start $start -End $end
        Write-Host "Updated Antigravity config rules: $primaryAgentsMd" -ForegroundColor Green

        $legacyAgentsMd = Join-Path $HOME '.gemini\AGENTS.md'
        Add-ManagedBlock -Path $legacyAgentsMd -BlockContent $ruleContent -Start $start -End $end
        Write-Host "Updated Antigravity root rules: $legacyAgentsMd" -ForegroundColor Green
    }
}

if ($Platform -in @('Claude','Both')) {
    $dest = Join-Path $HOME '.claude\skills\devsecops-maximum'
    Install-Skill $dest
    $scriptDest = Join-Path $dest 'scripts'
    New-Item -ItemType Directory -Force -Path $scriptDest | Out-Null
    Copy-Item (Join-Path $PackageRoot 'skill\scripts\Emit-Claude-DevSecOpsContext.ps1') (Join-Path $scriptDest 'Emit-Claude-DevSecOpsContext.ps1') -Force

    if (-not $NoGlobalInstructions) {
        $source = Join-Path $PackageRoot 'platform\claude\global-instructions.md'
        $content = Get-Content -LiteralPath $source -Raw
        $target = Join-Path $HOME '.claude\CLAUDE.md'
        Add-ManagedBlock -Path $target -BlockContent $content -Start $start -End $end
        Write-Host "Installed Claude Code global instructions: $target" -ForegroundColor Green
    }
}

Write-Host "`nInstallation completed. Restart agents if needed, then run .\scripts\Test-DevSecOpsInstall.ps1 -Platform $Platform" -ForegroundColor Cyan
