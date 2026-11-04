# Severity and Triage

Use Critical / High / Medium / Low / Informational. Consider exploitability, exposure, impact, affected data, privileges required, user interaction, compensating controls, and business context.

CVSS:
- Use CVSS 4.0 when the necessary metrics are known.
- Do not fabricate a numeric score.
- If the score is contextual or provisional, label it clearly.
- Scanner severity is a signal, not a substitute for triage.

Suggested response targets (adapt to organization policy):
- Critical: immediate containment and incident/security-owner escalation.
- High: prioritize remediation before release.
- Medium: scheduled remediation with owner and due date.
- Low: track and remediate through normal hardening.
- Informational: document when useful.

Exceptions must include:
- Finding ID and scope.
- Business justification.
- Risk owner and approver.
- Compensating controls.
- Expiry/review date.
- Remediation plan.
