[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [ValidateSet('Antigravity','Claude','Both')]
    [string]$Platform='Both'
)
$start = '<!-- DEVSECOPS-MAXIMUM:START -->'
$end = '<!-- DEVSECOPS-MAXIMUM:END -->'

function Remove-Block($path) {
    if (Test-Path $path) {
        $v = Get-Content $path -Raw
        $p = '(?s)\r?\n?' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end) + '\r?\n?'
        $v = [regex]::Replace($v, $p, "`r`n")
        if ([string]::IsNullOrWhiteSpace($v.Trim())) {
            if ($PSCmdlet.ShouldProcess($path, 'Remove empty managed instruction file')) {
                Remove-Item $path -Force -ErrorAction SilentlyContinue
            }
        } else {
            if ($PSCmdlet.ShouldProcess($path, 'Remove managed DevSecOps block')) {
                Set-Content $path $v.TrimEnd() -Encoding UTF8
            }
        }
    }
}

if ($Platform -in @('Antigravity','Both')) {
    $p = Join-Path $HOME '.gemini\config\skills\devsecops-maximum'
    if ($PSCmdlet.ShouldProcess($p, 'Remove installed skill directory')) {
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    }
    # Remove standalone rule file
    $ruleFile = Join-Path $HOME '.gemini\config\rules\devsecops.md'
    if (Test-Path $ruleFile) {
        if ($PSCmdlet.ShouldProcess($ruleFile, 'Remove standalone DevSecOps rule')) {
            Remove-Item $ruleFile -Force -ErrorAction SilentlyContinue
        }
    }
    Remove-Block (Join-Path $HOME '.gemini\config\AGENTS.md')
    Remove-Block (Join-Path $HOME '.gemini\AGENTS.md')
    Write-Host "Uninstalled Antigravity DevSecOps components." -ForegroundColor Green
}

if ($Platform -in @('Claude','Both')) {
    $p = Join-Path $HOME '.claude\skills\devsecops-maximum'
    if ($PSCmdlet.ShouldProcess($p, 'Remove installed skill directory')) {
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    }
    Remove-Block (Join-Path $HOME '.claude\CLAUDE.md')
    Write-Host "Uninstalled Claude Code DevSecOps components." -ForegroundColor Green
}

Write-Host 'Uninstall completed cleanly.' -ForegroundColor Green
