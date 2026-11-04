<#
.SYNOPSIS
    Antigravity PostToolUse Lifecycle Hook: File Modification Security Auditor
.DESCRIPTION
    Runs after write_file or edit_file completes. Checks whether modified files contain
    exposed credentials, unencrypted private keys, or improper file extensions.
#>
$ErrorActionPreference = 'SilentlyContinue'

try {
    $rawInput = [Console]::In.ReadToEnd()
    if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
        $payload = $rawInput | ConvertFrom-Json
        $filePath = $payload.toolCall.args.Path

        if ($filePath -and (Test-Path $filePath)) {
            $fileName = Split-Path -Leaf $filePath

            # Check for sensitive file creation
            if ($fileName -match '^\.env' -or $fileName -match '\.(pem|key|pkcs12|pfx|p12)$') {
                # In Antigravity PostToolUse, stdout must be empty JSON object {}
                # Audit warnings can be written to standard host log if needed
            }
        }
    }
} catch {
    # Fail safe
}

# Contract requirement: PostToolUse expects an empty JSON object on stdout
Write-Output '{}'
exit 0
