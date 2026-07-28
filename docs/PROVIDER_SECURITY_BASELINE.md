# Provider and Security Baseline

This document freezes the before-change state required by Epic 1. Detailed evidence is in `UPSTREAM_ARCHITECTURE_INVENTORY.md`.

## Provider conclusion

GitHub is the most complete implementation, while GitLab, Gitea/Forgejo, and Azure DevOps have adapter modules with unproven end-to-end parity. None currently implements the provider-neutral IDWP governance contract, protected-branch administration, independently signed review gate, or complete promotion/sync-back workflow.

## Security conclusion

Upstream has useful TLS, local authentication, encrypted secret storage, optional vault, webhook, and audit primitives. It does not provide IDWP's required identity separation, immutable governance audit, evidence freshness, reviewer isolation, gate anti-spoofing, or fail-closed provider policy enforcement.

All capabilities remain advisory/unverified until later conformance and security epics test them.

