# Software Supply Chain Security

- Commit lockfiles and use reproducible/controlled builds where practical.
- Pin critical dependencies and build actions; avoid floating tags for production.
- Use trusted registries and verify package integrity/provenance.
- Review maintainers, release history, package names, and install scripts for suspicious behavior.
- Scan direct and transitive dependencies for known vulnerabilities.
- Generate CycloneDX or SPDX SBOMs for release artifacts when required.
- Track dependency owner, version, license, source, and update cadence.
- Avoid unmaintained packages and unnecessary dependencies.
- Review CI workflow permissions, third-party actions, runner isolation, and secret exposure.
- Protect release signing keys and publish signed artifacts/attestations where supported.
- Treat dependency update bots and generated PRs as untrusted until reviewed.
