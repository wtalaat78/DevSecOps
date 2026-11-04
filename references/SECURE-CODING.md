# Secure Coding Reference

## General
- Validate untrusted data at boundaries; use allowlists and typed schemas.
- Encode output for HTML, JavaScript, URL, SQL, shell, and other destination contexts.
- Prefer safe framework APIs and parameterized queries.
- Avoid dynamic evaluation, shell concatenation, unsafe deserialization, and custom crypto.
- Fail closed for authorization and security-sensitive decisions.
- Use generic external errors and detailed, access-controlled internal diagnostics.
- Bound request sizes, timeouts, concurrency, pagination, and expensive operations.

## Authentication and authorization
- Use established identity providers and standard protocols.
- Enforce authorization server-side on every request and resource.
- Check tenant, owner, role, and action at the object level.
- Validate token signature, issuer, audience, expiry, not-before, and allowed algorithms.
- Store passwords using modern password hashing (Argon2id preferred where supported).
- Protect sessions with Secure, HttpOnly, and appropriate SameSite cookies.
- Rotate sessions after authentication/privilege changes; support revocation and expiry.

## Web
- Apply context-aware output encoding and a restrictive CSP.
- Use CSRF protection for cookie-authenticated state-changing requests.
- Configure CORS with explicit trusted origins; never reflect arbitrary Origin values.
- Set HSTS after confirming HTTPS readiness.
- Avoid open redirects and unsafe postMessage origin checks.
- Protect upload/download paths and content handling.

## API
- Validate request and response schemas.
- Avoid mass assignment; explicitly map writable fields.
- Enforce object-level and function-level authorization.
- Apply per-user/IP/tenant rate limits and resource quotas.
- Restrict outbound destinations to reduce SSRF; validate resolved IPs and redirects.
- Verify webhook signatures and timestamps; prevent replay.

## Data and secrets
- Use secret managers or workload identity.
- Keep secrets out of source, logs, telemetry, container layers, and artifacts.
- Encrypt sensitive data in transit and at rest based on risk.
- Minimize collection, access, retention, and exposure.
- Redact PII and credentials from logs and reports.

## Files and operating system
- Generate storage names; do not trust user-supplied paths.
- Normalize and constrain paths to an approved root.
- Validate file size, type, content, and malware scanning requirements.
- Avoid shell invocation; if unavoidable, use argument arrays and strict allowlists.
- Run with least privilege and isolate untrusted workloads.

## Desktop and mobile
- Store secrets in platform-provided secure storage.
- Validate TLS certificates; do not ship debug trust overrides.
- Request minimum permissions.
- Secure deep links, IPC, custom URL handlers, and update channels.
- Sign releases and validate update/package integrity.
