# Reviewer Service Guidelines

## Scope

Apply to reviewer jobs, isolated workspaces, OpenCode execution, findings,
rechecks, attestations, and reviewer-provider actions.

## Separation of Duties

- Reviewer identity, credentials, process, configuration, workspace, and model
  runtime are separate from implementation.
- Reviewer workspaces are exact-commit and read-only.
- Implementation cannot accept, close, resolve, sign, or spoof reviewer state.
- Leases and authoritative job state survive restart.

## Findings

Findings use typed structured output and bind to the exact reviewed commit.
Provider discussion, implementation response, fix evidence, and reviewer
recheck remain in the same visible conversation.

## Attestations

Attestations identify commit, reviewer identity/runtime, actual model,
telemetry provenance, findings, validation, and signature. A new commit
invalidates prior acceptance unless the specification explicitly permits reuse.
