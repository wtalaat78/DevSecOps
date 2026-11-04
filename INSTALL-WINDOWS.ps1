Set-ExecutionPolicy -Scope Process Bypass
& (Join-Path $PSScriptRoot 'scripts\Install-DevSecOps.ps1') -Platform Both
