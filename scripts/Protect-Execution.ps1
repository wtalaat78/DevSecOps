<#
.SYNOPSIS
    Antigravity PreToolUse Lifecycle Hook: DevSecOps Execution Safety Gate
.DESCRIPTION
    Intercepts run_command tool calls before execution. Inspects commands for destructive,
    privileged, or dangerous patterns and returns decision 'deny' or 'force_ask'.
#>
$ErrorActionPreference = 'SilentlyContinue'

try {
    $rawInput = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($rawInput)) {
        # Fallback allow if no payload provided
        Write-Output '{"decision":"allow"}'
        exit 0
    }

    $payload = $rawInput | ConvertFrom-Json
    $commandLine = $payload.toolCall.args.CommandLine

    if ([string]::IsNullOrWhiteSpace($commandLine)) {
        Write-Output '{"decision":"allow"}'
        exit 0
    }

    # High-Risk / Destructive Command Patterns
    $destructivePatterns = @(
        @{ Regex = 'git\s+push\s+.*(--force|-f\b)'; Reason = 'Force pushing to git repositories can overwrite team commits.' },
        @{ Regex = 'git\s+reset\s+--hard'; Reason = 'Hard git resets permanently destroy uncommitted work and local changes.' },
        @{ Regex = 'git\s+clean\s+-[a-zA-Z]*f'; Reason = 'Forced git clean deletes untracked workspace files.' },
        @{ Regex = 'rmdir\s+/[sS]\s+/[qQ]\s+[a-zA-Z]:\\'; Reason = 'Root directory recursive deletion detected.' },
        @{ Regex = '(?i)drop\s+(database|table|schema)\b'; Reason = 'Destructive SQL database drop statement detected.' },
        @{ Regex = '(?i)truncate\s+table\b'; Reason = 'Destructive SQL table truncation detected.' },
        @{ Regex = 'kubectl\s+delete\s+(all|namespace|deployment|node|pv|pvc)\b'; Reason = 'Destructive Kubernetes cluster resource deletion detected.' },
        @{ Regex = 'terraform\s+destroy\b'; Reason = 'Infrastructure-as-code destruction command detected.' },
        @{ Regex = '(?i)(curl|wget|iwr)\s+.*\|\s*(bash|sh|powershell|pwsh|cmd)'; Reason = 'Piping untrusted remote scripts directly into shell interpreter is prohibited.' }
    )

    foreach ($rule in $destructivePatterns) {
        if ($commandLine -match $rule.Regex) {
            $response = [pscustomobject]@{
                decision = "force_ask"
                reason = "DevSecOps Policy Guardrail: $($rule.Reason)"
            }
            Write-Output ($response | ConvertTo-Json -Compress)
            exit 0
        }
    }

    # Default: Safe command
    Write-Output '{"decision":"allow"}'
} catch {
    # Fail-safe: allow on error so agent is not locked up, but log
    Write-Output '{"decision":"allow"}'
}
exit 0
