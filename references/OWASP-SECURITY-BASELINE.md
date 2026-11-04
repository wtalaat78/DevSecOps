# OWASP Security Baseline

Use current official OWASP materials for project-specific controls; do not treat this summary as a replacement for the standards.

## Web applications
Use OWASP Top 10 as a risk-awareness taxonomy. Evaluate at least:
- Broken access control and object-level authorization.
- Security misconfiguration and unsafe defaults.
- Software supply-chain failures and vulnerable components.
- Cryptographic failures and sensitive-data exposure.
- Injection and unsafe interpreter use.
- Insecure design and missing abuse-case controls.
- Authentication and session failures.
- Integrity and logging/monitoring failures.
- SSRF and unsafe outbound requests.

## APIs
Use OWASP API Security Top 10. Test:
- Broken object-level authorization (BOLA).
- Broken authentication.
- Broken object-property-level authorization / mass assignment.
- Unrestricted resource consumption.
- Broken function-level authorization.
- Sensitive business-flow abuse.
- SSRF.
- Security misconfiguration.
- Improper inventory management.
- Unsafe consumption of third-party APIs.

## Application verification
For each endpoint, document:
- Authentication required?
- Authorization policy and object ownership check?
- Input schema and size limits?
- Rate/abuse limits?
- Sensitive output minimization?
- Audit events?
- Error behavior?
- Negative tests?

Official references:
- https://owasp.org/www-project-top-ten/
- https://owasp.org/www-project-api-security/
- https://cheatsheetseries.owasp.org/
