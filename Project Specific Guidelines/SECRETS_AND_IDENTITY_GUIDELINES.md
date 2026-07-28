# Secrets and Identity Guidelines

## Scope

Apply to credentials, tokens, keys, certificates, secret references, and
implementation/workflow/reviewer/operator identities.

## Storage

- Never commit durable plaintext secrets or plausible example credentials.
- Examples use explicit placeholders and secret-store references.
- Runtime secrets come from an approved OS/cloud secret store or protected
  mount, never command arguments, logs, PR text, fixtures, or chat.
- Missing secrets fail clearly without asking users to paste them into chat.

## Identity Separation

- Implementation, workflow, and reviewer identities are distinct and
  least-privileged.
- Reviewer credentials cannot write implementation source or impersonate the
  workflow gate.
- Rotation and access tests must not disclose secret values.

## Testing

Use fake references in deterministic tests. Live tests use dedicated scoped
identities, sanitized output, safe limits, and documented cleanup.
