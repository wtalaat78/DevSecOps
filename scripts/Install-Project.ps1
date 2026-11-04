[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    [ValidateSet('Antigravity','Claude','Both')]
    [string]$Platform='Both',
    [switch]$Force
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$project = (Resolve-Path -LiteralPath $ProjectPath).Path
$skillSrc = Join-Path $root 'skill'
$start = '<!-- DEVSECOPS-MAXIMUM:START -->'
$end = '<!-- DEVSECOPS-MAXIMUM:END -->'

function Copy-Skill($dest) {
    if (Test-Path $dest) {
        if (-not $Force) { throw "Destination exists: $dest. Re-run with -Force to back up and replace." }
        Move-Item -LiteralPath $dest -Destination "$dest.backup-$(Get-Date -Format yyyyMMdd-HHmmss)" -Force
    }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item (Join-Path $skillSrc '*') $dest -Recurse -Force
    # Include references and templates for project-isolated progressive disclosure
    $refDest = Join-Path $dest 'references'
    New-Item -ItemType Directory -Force -Path $refDest | Out-Null
    Copy-Item (Join-Path $root 'references\*') $refDest -Recurse -Force

    $tplDest = Join-Path $dest 'templates'
    New-Item -ItemType Directory -Force -Path $tplDest | Out-Null
    Copy-Item (Join-Path $root 'templates\*') $tplDest -Recurse -Force
}

function Merge-Block($path, $text) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $old = if (Test-Path $path) { Get-Content $path -Raw } else { '' }
    $pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
    $block = "$start`r`n$text`r`n$end"
    if ($old -match $pattern) {
        $old = [regex]::Replace($old, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block })
    } else {
        $prefix = if ([string]::IsNullOrWhiteSpace($old)) { '' } else { $old.TrimEnd() + "`r`n`r`n" }
        $old = $prefix + $block + "`r`n"
    }
    Set-Content -LiteralPath $path -Value $old -Encoding UTF8
}

if ($Platform -in @('Antigravity','Both')) {
    Copy-Skill (Join-Path $project '.agents\skills\devsecops-maximum')
    $rules = Join-Path $project '.agents\rules'
    New-Item -ItemType Directory -Force -Path $rules | Out-Null
    Copy-Item (Join-Path $root 'platform\antigravity\workspace-rule.md') (Join-Path $rules 'devsecops.md') -Force

    # Also install hooks if present
    $hookSrc = Join-Path $root 'platform\antigravity\hooks.json'
    if (Test-Path $hookSrc) {
        Copy-Item $hookSrc (Join-Path $project '.agents\hooks.json') -Force
    }
    Write-Host 'Installed Antigravity workspace skill, rules, and safety hooks.' -ForegroundColor Green
}

if ($Platform -in @('Claude','Both')) {
    Copy-Skill (Join-Path $project '.claude\skills\devsecops-maximum')
    $claudeText = Get-Content (Join-Path $root 'platform\claude\global-instructions.md') -Raw
    Merge-Block (Join-Path $project 'CLAUDE.md') $claudeText
    Write-Host 'Installed Claude Code project skill and CLAUDE.md policy.' -ForegroundColor Green
}

Write-Host 'Project installation complete. Review and commit policy files if they should apply to teammates.' -ForegroundColor Cyan
