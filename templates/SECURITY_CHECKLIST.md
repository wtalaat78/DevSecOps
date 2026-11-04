# Secure Development Checklist

## Design
- [ ] Assets, data classification, entry points, and trust boundaries identified
- [ ] Threat model reviewed (STRIDE analysis completed)
- [ ] Authentication and server-side authorization designed
- [ ] Tenant isolation and object-level authorization considered
- [ ] Abuse/rate limits and resource bounds designed

## Implementation
- [ ] Input validation and context-aware output encoding applied
- [ ] Parameterized database access (no dynamic SQL concatenation)
- [ ] Safe file handling and path traversal constraints
- [ ] Secrets kept out of source, logs, telemetry, and artifacts
- [ ] Secure session and token lifecycle (revocation, rotation, expiry)
- [ ] Safe error messages (no stack traces or internal topologies)
- [ ] TLS validation and secure headers/configuration enforced

## AI & LLM Systems (If Applicable)
- [ ] Untrusted prompt inputs and retrieved context isolated from instructions
- [ ] LLM completions sanitized; no dynamic shell/SQL execution of generated text
- [ ] Agent tools enforce least privilege, schema validation, and human confirmation for destructive actions
- [ ] Prompts and RAG data scrubbed for secrets and PII before model submission
- [ ] Model weights vetted and cryptographic checksums verified

## Supply Chain and Infrastructure
- [ ] Direct and transitive dependencies scanned for known vulnerabilities
- [ ] Ecosystem lockfiles committed and verified
- [ ] Secrets scan executed (Gitleaks)
- [ ] Static Application Security Testing (SAST) executed (Semgrep)
- [ ] Container and IaC scans executed where applicable (Trivy, Checkov)
- [ ] Software Bill of Materials (SBOM) generated (Syft)
- [ ] CI/CD pipeline permissions, runner isolation, and secrets reviewed

## Verification and Release
- [ ] Authentication and authorization negative tests pass
- [ ] Security regression tests pass
- [ ] Findings triaged and verified via re-testing
- [ ] Security exceptions approved, documented, and time-bound
- [ ] Checks not run clearly documented with justification
- [ ] Rollback, incident response, and logging considerations reviewed
- [ ] Honest release recommendation recorded (BLOCKED / CONDITIONAL / READY FOR REVIEW)
