# Cloud, IaC, and Container Security

## Cloud IAM
- Prefer short-lived workload identity over static keys.
- Use least privilege and scoped roles.
- Review wildcard actions/resources and privilege-escalation paths.
- Separate environments and production credentials.
- Enable audit logging and alerting for privileged changes.

## Network and data services
- Minimize public endpoints; restrict ingress and egress.
- Do not expose databases, caches, admin panels, or metadata services publicly.
- Enforce TLS and private connectivity where appropriate.
- Encrypt storage and backups; test restore procedures.
- Avoid public object-storage access unless explicitly required and reviewed.

## Infrastructure as Code
- Scan Terraform, CloudFormation, Kubernetes, Helm, and related manifests.
- Avoid plaintext secrets in state and plan artifacts.
- Pin providers/modules and review source/provenance.
- Use policy-as-code and peer review for production changes.
- Do not apply infrastructure changes without explicit approval.

## Containers
- Use trusted minimal base images, pin digests where practical, and rebuild regularly.
- Run as non-root; drop unnecessary Linux capabilities.
- Use read-only filesystems and resource limits where feasible.
- Do not bake secrets into image layers or build arguments.
- Scan image and filesystem for vulnerabilities and misconfigurations.
- Generate SBOMs and sign/attest artifacts where supported.
- Separate build and runtime dependencies; use multi-stage builds.

## Kubernetes
- Apply namespace isolation, RBAC least privilege, and Pod Security Standards.
- Avoid privileged pods, hostPath, hostNetwork, and hostPID unless justified.
- Set resource requests/limits and securityContext.
- Use network policies and secret encryption/management.
- Restrict API server access and audit administrative actions.
