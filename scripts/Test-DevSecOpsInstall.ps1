[CmdletBinding()]
param(
    [ValidateSet('Antigravity', 'Claude', 'Both')]
    [string]$Platform = 'Both'
)
$ErrorActionPreference = 'Continue'

Write-Host "=== DevSecOps Maximum Installation Verification ($Platform) ===" -ForegroundColor Cyan

$checks = @()

if ($Platform -in @('Antigravity', 'Both')) {
    $checks += @{
        Name = 'Antigravity Skill Definition'
        Path = (Join-Path $HOME '.gemini\config\skills\devsecops-maximum\SKILL.md')
        Platform = 'Antigravity'
    }
    # Check either config\rules\devsecops.md, config\AGENTS.md, or legacy AGENTS.md
    $agyRulePaths = @(
        (Join-Path $HOME '.gemini\config\rules\devsecops.md'),
        (Join-Path $HOME '.gemini\config\AGENTS.md'),
        (Join-Path $HOME '.gemini\AGENTS.md')
    )
    $foundAgyRule = $agyRulePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    $checks += @{
        Name = 'Antigravity Global Rule'
        Path = if ($foundAgyRule) { $foundAgyRule } else { $agyRulePaths[0] }
        Platform = 'Antigravity'
    }
}

if ($Platform -in @('Claude', 'Both')) {
    $checks += @{
        Name = 'Claude Code Skill Definition'
        Path = (Join-Path $HOME '.claude\skills\devsecops-maximum\SKILL.md')
        Platform = 'Claude'
    }
    $checks += @{
        Name = 'Claude Code Global Instructions'
        Path = (Join-Path $HOME '.claude\CLAUDE.md')
        Platform = 'Claude'
    }
}

$failed = 0
foreach ($c in $checks) {
    if (Test-Path $c.Path) {
        Write-Host "  [PASS] $($c.Name)" -ForegroundColor Green
        Write-Host "         Path: $($c.Path)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [MISSING] $($c.Name)" -ForegroundColor Red
        Write-Host "            Path: $($c.Path)" -ForegroundColor DarkGray
        $failed++
    }
}

Write-Host "`n=== Security Scanner Tool Availability ===" -ForegroundColor Cyan
$scanners = @(
    @{ Tool = 'git'; Desc = 'Version Control' },
    @{ Tool = 'gitleaks'; Desc = 'Secret Detection' },
    @{ Tool = 'semgrep'; Desc = 'SAST Engine' },
    @{ Tool = 'osv-scanner'; Desc = 'SCA Dependency Vulnerabilities' },
    @{ Tool = 'trivy'; Desc = 'Container & Filesystem Scanner' },
    @{ Tool = 'checkov'; Desc = 'IaC Security Scanner' },
    @{ Tool = 'syft'; Desc = 'SBOM Generator' },
    @{ Tool = 'grype'; Desc = 'Vulnerability Matcher' }
)

foreach ($item in $scanners) {
    $cmd = Get-Command $item.Tool -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host "  [AVAILABLE] $($item.Tool.PadRight(12)) ($($item.Desc))" -ForegroundColor Green
        Write-Host "              $($cmd.Source)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [OPTIONAL]  $($item.Tool.PadRight(12)) ($($item.Desc)) - Not found on PATH" -ForegroundColor DarkGray
    }
}

Write-Host "`n=== Native Language Package Manager Audit Tools ===" -ForegroundColor Cyan
$ecosystems = @('npm', 'pnpm', 'pip', 'cargo', 'go', 'dotnet')
foreach ($eco in $ecosystems) {
    $cmd = Get-Command $eco -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host "  [AVAILABLE] $($eco.PadRight(10)) -> $($cmd.Source)" -ForegroundColor Green
    }
}

if ($failed -gt 0) {
    Write-Host "`n[FAIL] $failed required component(s) missing for platform '$Platform'." -ForegroundColor Red
    exit 1
}

Write-Host "`n[OK] All components for platform '$Platform' are installed and verified." -ForegroundColor Green
