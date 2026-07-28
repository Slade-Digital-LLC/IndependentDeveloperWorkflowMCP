# Independent Development Workflow Platform - Failure Modes and Recovery

**Status:** Normative resilience specification  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

Failures are persisted states, not exceptional console messages. The system blocks unsafe progress, exposes the cause, and provides an idempotent recovery path.

## 2. Failure Classification

- **Transient:** retry with backoff and idempotency.
- **Blocked:** requires implementation, reviewer, provider, or operator action.
- **Permanent:** cannot complete without a new plan or cancellation.
- **Security:** fail closed, alert, preserve evidence, restrict retries.
- **Data Integrity:** stop affected workflow and reconcile/restore.
- **Advisory Limitation:** provider cannot enforce required control.

## 3. Upstream wshm Failures

### Upstream build or tests fail after rebase

Detection: CI compatibility suite.  
Action: block upgrade; retain current pinned version; update `PATCHES.md`; inspect API/schema/provider changes.  
Recovery: repair isolated patches or reject candidate upstream revision.

### Upstream changes a provider or agent interface

Detection: compilation, conformance, and contract tests.  
Action: block release; adapt wshm integration layer only.  
Recovery: preserve domain and MCP contracts; add migration notes.

### Upstream license or dependency obligations change

Detection: license/SBOM diff.  
Action: block upgrade and external distribution; legal/compliance review.  
Recovery: remain pinned, replace dependency, or adopt new decision.

## 4. Provider Failures

### Provider API unavailable or rate limited

Persist retryable ProviderOperation, apply bounded backoff, expose blocked state, and reconcile before resuming.

### Webhook missed, duplicated, or reordered

Deduplicate by delivery/event key; never trust ordering alone; periodic reconciliation reloads authoritative provider state.

### Provider policy drift

If branch protection, required gate, identity, or hook configuration weakens, gate becomes failing and production integration stops. Alert operators.

### Provider head differs from expected commit

Mark review/validation stale, cancel queued integration, reload change request, and require review/recheck as policy dictates.

### Provider merges outside IDWP

Record a security event, stop dependent promotion, reconcile commits, alert, and require an operator incident decision. Do not silently mark the workflow successful.

### Conversation manually resolved

If IDWP finding is not reviewer-accepted, keep gate failing and reopen when adapter supports it.

### Provider lacks required capability

Classify Advisory/Unsupported. Block production use unless an approved equivalent control is active.

## 5. Reviewer Failures

### Reviewer worker crashes

Lease expires; another worker may reclaim. Late results from expired lease are rejected.

### OpenCode process hangs

Terminate process group after timeout, preserve diagnostics, record cost incurred, retry according to policy.

### Wrong commit checked out

Reject run before provider publication; destroy/quarantine workspace; create fresh attempt.

### Malformed or incomplete reviewer output

Schema validation fails. A bounded repair attempt may run and is separately costed. No inferred approval.

### Reviewer publishes provider comments but attestation submission fails

Reconcile provider references and resume attestation submission idempotently. Gate remains non-passing until accepted by Governance.

### Attestation signature invalid or key revoked

Reject result, alert security, rotate key/credential, and require fresh review.

### Reviewer model unavailable

Use only policy-approved fallback. Record requested and actual route. If no approved route exists, remain blocked.

### Reviewer service compromised

Disable reviewer identity and signing key, fail all review gates, preserve evidence, rotate credentials, inspect affected reviews, and require re-review as incident policy determines.

## 6. Implementation Failures

### Validation fails

Workflow returns to implementation state. Failure and evidence remain in plan/audit. No commit/integration gate pass.

### Implementation rejects a finding

Finding moves to UnderDiscussion. Discussion continues on provider. Only reviewer agreement or explicit human exception permits no-change closure.

### Implementation pushes after approval

Immediate invalidation of approval, validation freshness, and gate. New review/recheck required.

### Implementation abandons session

Workflow remains durable. A new authorized session may resume with a new AgentSession and WorkRequest.

### Local finalization fails

Remote promotion remains complete. Workflow is blocked in LocalFinalizationRequired; return safe corrective commands and expected commits. Do not rewrite production history.

## 7. Workflow/Persistence Failures

### Governance service restarts mid-transition

On startup, scan incomplete transitions/provider operations and reconcile. Idempotency prevents duplicate effects.

### Database unavailable

Reject mutations; provider webhooks may be durably queued only if the queue is independent and secure. Do not perform unrecorded provider side effects.

### Partial database commit/provider side effect

ProviderOperation remains pending/unknown; reconciliation finds external result and attaches it or retries safely.

### Concurrency conflict

Reject stale caller with current state/version. Do not auto-merge conflicting decisions.

### Migration failure

Stop deployment, restore/roll back according to tested plan, keep old service active where possible, and do not run mixed incompatible versions.

### Backup restore behind provider state

Load backup into isolated recovery, query providers, and reconcile forward. Never push restored stale state over provider history.

## 8. MCP/API Failures

### Client disconnect during long action

Action continues only if already durably accepted. Client uses idempotency key and status polling to resume.

### Duplicate mutation

Return original/current result. Do not repeat provider side effect.

### Authentication expired

Reject safely; no partial privileged action. Client renews credential and retries with same idempotency key.

### Oversized payload/log

Reject or require artifact reference. Never truncate security-critical state into a misleading success.

## 9. AI Usage and Cost Failures

### Telemetry event missing

Mark AIRequest telemetry Incomplete/Unavailable; attempt reconciliation; cost remains unknown, not zero.

### Duplicate telemetry

Deduplicate by event/request/attempt key and preserve conflict evidence.

### Token counts conflict

Store source versions, apply precedence rules, flag Unreconciled, and expose discrepancy in reporting.

### Model route differs from requested

Record both. Alert if actual route violates approved policy.

### Rate card missing

Store usage; cost status Unpriced. Backfill through versioned cost record after rate card approval.

### Shared release cost cannot be allocated

Keep in UnallocatedSharedWork bucket; do not duplicate full cost across features.

### Currency mismatch

Report separate currency totals unless an approved effective-dated exchange rate exists.

## 10. Branch and Correlation Failures

### Branch renamed

Update provider reference/name; preserve DevelopmentBranch ID and historical names.

### Branch deleted early

Preserve lineage and commits. Block dependent steps if source ref required; recreate only through audited policy action.

### Request lacks Feature Branch ID

Reject governed file-changing telemetry/request ingestion or place it in a visible Unattributed exception queue. Do not silently assign to the current branch.

### Multiple workflows claim one active branch

Enforce uniqueness/lease; require explicit workflow relationship or operator resolution.

## 11. Local/Self-Hosted Git Failures

### Server-side hook unavailable or modified

Provider mode falls to Advisory/Unsupported; production gate fails.

### Central repository filesystem permissions drift

Alert and block integration until least-privilege ownership is restored.

### No discussion system

Review may run, but production workflow is blocked unless an IDWP-hosted equivalent discussion module is configured.

## 12. Operator Recovery Requirements

The web UI must show:

- failed component and category;
- affected workflow/repository/commit;
- current safe state;
- automatic retries and next time;
- exact manual action required;
- whether action is destructive or security-sensitive;
- correlated logs and evidence;
- cost incurred;
- audit trail;
- recovery and cancellation controls appropriate to role.

## 13. Chaos and Recovery Tests

Test at least:

- service/database/reviewer restart in every long-running phase;
- duplicate/reordered/missed webhooks;
- provider outage/rate limit;
- review process kill and lease recovery;
- wrong SHA and invalid signature;
- policy drift;
- manual merge/resolve attempt;
- database restore behind provider;
- upstream rebase interface break;
- missing/duplicate/conflicting cost telemetry;
- local finalization failure;
- branch rename/deletion;
- advisory provider production attempt.
