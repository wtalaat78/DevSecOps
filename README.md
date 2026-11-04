# DevSecOps Maximum — Antigravity + Claude Code

A portable, cross-platform enterprise DevSecOps skill bundle and Antigravity Plugin. It provides continuous security-by-design workflows, lifecycle safety guardrails, multi-stack automated vulnerability scanning, CI/CD pipeline blueprints, and comprehensive security references (including OWASP Top 10 for LLMs).

---

## What It Does

- **Dual-Platform Architecture:** Installs globally or per-project for both Google Antigravity and Claude Code.
- **Antigravity Plugin & Safety Hooks:** Native `plugin.json` manifest and `hooks.json` lifecycle hooks that intercept destructive shell commands (`PreToolUse`) and audit file modifications for leaked credentials (`PostToolUse`).
- **Always-On Security Policy:** Integrates into Antigravity global rules (`~/.gemini/config/rules/` and `AGENTS.md`) and Claude Code (`~/.claude/CLAUDE.md`).
- **Multi-Stack Automated Scanning:**
  - **Secrets:** Gitleaks with custom enterprise regexes and automatic log redaction.
  - **SAST:** Curated baseline Semgrep offline rules for SQLi, command injection, crypto flaws, and CORS.
  - **SCA / Dependencies:** OSV-Scanner plus zero-install native audits (`npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `dotnet list package`).
  - **Containers & IaC:** Trivy (with `--exit-code 1` and `--severity HIGH,CRITICAL`) and Checkov.
  - **SBOM:** Syft CycloneDX generation.
- **CI/CD & Pre-Commit Blueprints:** Ready-to-use GitHub Actions workflow (`.github/workflows/devsecops-pipeline.yml`) and `.pre-commit-config.yaml`.
- **AI & LLM Security:** Complete reference guide covering the OWASP Top 10 for LLM Applications (prompt injection, excessive agency, insecure output handling, context leakage).
- **Safe-by-Default Remediation:** Destructive commands, production changes, and credential rotations require explicit human confirmation.

---

## Package Contents

```text
DevSecOps-Maximum/
├── plugin.json                              # Antigravity Plugin manifest
├── README.md                                # Comprehensive documentation
├── INSTALL-WINDOWS.ps1                      # Windows 1-click installer
├── INSTALL-UNIX.sh                          # Linux / macOS / WSL 1-click installer
├── .pre-commit-config.yaml                  # Pre-commit secret and SAST hooks
├── .github/
│   └── workflows/
│       └── devsecops-pipeline.yml           # Turnkey GitHub Actions CI/CD release gate
├── config/
│   ├── .gitleaks.toml                       # Extended enterprise secret detection patterns
│   └── semgrep.yml                          # Curated baseline offline SAST rules
├── platform/
│   ├── antigravity/
│   │   ├── global-rule.md                   # Always-on policy for Antigravity
│   │   ├── workspace-rule.md                # Project-level Antigravity rule
│   │   └── hooks.json                       # Antigravity PreToolUse / PostToolUse hooks
│   └── claude/
│       ├── global-instructions.md           # Always-on policy for Claude Code
│       ├── optional-settings-hook.json      # Claude prompt submit hook
│       └── HOOKS-OPTIONAL.md                # Claude hook documentation
├── references/
│   ├── CLOUD-IAC-CONTAINER.md               # Cloud, IaC, and container security
│   ├── COMPLIANCE-PRIVACY.md                # GDPR, HIPAA, PCI-DSS baselines
│   ├── OWASP-SECURITY-BASELINE.md           # Web & API OWASP Top 10
│   ├── OWASP-LLM-GENAI.md                   # OWASP Top 10 for LLMs and AI Agents
│   ├── SECURE-CODING.md                     # Language-agnostic secure implementation
│   ├── SEVERITY-AND-TRIAGE.md               # Triage matrix & CVSS 4.0 guidance
│   └── SUPPLY-CHAIN.md                      # Dependency provenance & lockfile hygiene
├── scripts/
│   ├── Install-DevSecOps.ps1                # Global installer (PowerShell)
│   ├── Install-Project.ps1                  # Project-level installer (PowerShell)
│   ├── Invoke-DevSecOpsScan.ps1             # Multi-tool automated scanner with redaction
│   ├── Test-DevSecOpsInstall.ps1            # Installation verification script
│   ├── Uninstall-DevSecOps.ps1              # Clean uninstaller
│   ├── Protect-Execution.ps1                # Antigravity PreToolUse command guardrail
│   ├── Audit-FileChange.ps1                 # Antigravity PostToolUse file security audit
│   └── install.sh                           # Global installer (Bash for Unix/macOS)
├── skill/
│   ├── SKILL.md                             # Full DevSecOps workflow & instructions
│   └── scripts/
│       └── Emit-Claude-DevSecOpsContext.ps1 # Claude context injection helper
└── templates/
    ├── SECURITY_CHECKLIST.md                # Release verification checklist
    ├── SECURITY_EXCEPTIONS.md               # Time-bound exception register
    ├── SECURITY_REPORT.md                   # Executive & technical assessment report
    └── THREAT_MODEL.md                      # STRIDE threat model template
```

---

## Installation

### Windows (PowerShell)

Open PowerShell in the extracted directory:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Install-DevSecOps.ps1 -Platform Both
```

*Options:*
- `-Platform Antigravity` — Install only for Antigravity (`~/.gemini/config/`)
- `-Platform Claude` — Install only for Claude Code (`~/.claude/`)
- `-Platform Both` — Install for both agents (default)
- `-Force` — Overwrite existing skill directories after creating a timestamped backup

### Linux / macOS / WSL (Bash)

```bash
chmod +x INSTALL-UNIX.sh scripts/*.sh
./INSTALL-UNIX.sh --platform both
```

---

## Project Installation

To configure DevSecOps Maximum for a specific repository:

```powershell
.\scripts\Install-Project.ps1 -ProjectPath "C:\path\to\my-app" -Platform Both
```

This installs:
- **Antigravity:** `.agents/skills/devsecops-maximum/`, `.agents/rules/devsecops.md`, and `.agents/hooks.json`.
- **Claude Code:** `.claude/skills/devsecops-maximum/` and project `CLAUDE.md`.

---

## Verification

Verify that all files and scanners are correctly detected:

```powershell
.\scripts\Test-DevSecOpsInstall.ps1 -Platform Both
```

---

## Running Scans

To execute an automated local security scan:

```powershell
.\scripts\Invoke-DevSecOpsScan.ps1 -ProjectPath "C:\path\to\my-app"
```

*Optional flags:*
```powershell
.\scripts\Invoke-DevSecOpsScan.ps1 -ProjectPath "C:\path\to\my-app" -IncludeTrivy -IncludeCheckov -IncludeSbom
```

Reports are generated in `<ProjectPath>\security\reports\`:
- `devsecops-<timestamp>.md` — Clean Markdown summary table
- `devsecops-<timestamp>.json` — Machine-readable scan metadata
- `devsecops-<timestamp>.log` — Output log with automatic secret redaction

---

## CI/CD & Pre-Commit Setup

1. **Pre-Commit:** Copy `.pre-commit-config.yaml` to your repository root and run `pre-commit install`.
2. **GitHub Actions:** Copy `.github/workflows/devsecops-pipeline.yml` to your repository to enforce security gates on every Pull Request.
