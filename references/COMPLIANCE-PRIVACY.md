# Compliance and Privacy Mapping (Not Certification)

Determine applicability with legal, privacy, and compliance owners. This guide is a starting point, not legal advice or an audit opinion.

Potential frameworks:
- OWASP ASVS for application security verification requirements.
- NIST SSDF (SP 800-218) for secure software development practices.
- NIST Cybersecurity Framework for governance and risk outcomes.
- ISO/IEC 27001 for information security management systems.
- CIS Benchmarks for platform hardening.
- GDPR / local privacy law when personal data is processed.
- PCI DSS only where payment-card scope applies.

For each applicable requirement:
1. Identify scope and system boundary.
2. Map control objective to implementation evidence.
3. Identify control owner and review cadence.
4. Record gaps, compensating controls, and remediation dates.
5. Never state "compliant" solely because a scanner is clean.

Privacy checks:
- Data inventory and purpose limitation.
- Data minimization and retention schedule.
- Consent/legal basis where applicable.
- Access controls and audit trail.
- Encryption and key management.
- Data-subject rights and deletion workflow where applicable.
- Processor/subprocessor review.
- Breach response and notification process.
