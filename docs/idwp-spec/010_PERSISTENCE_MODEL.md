# Independent Development Workflow Platform - Persistence Model

**Status:** Normative logical persistence specification  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

This document defines durable logical data. It deliberately does not require MySQL, PostgreSQL, SQLite, or another engine until Epic 1 verifies wshm's supported persistence and migration framework.

The implementation should extend the upstream datastore when it provides the required consistency, security, and reporting behavior. A separate IDWP database or schema is allowed only when documented integration boundaries and transactions are sufficient.

## 2. Persistence Principles

- authoritative state is durable, not process-local;
- domain IDs are UUIDs or another stable internal format independent of providers;
- provider IDs are opaque references;
- append-only histories are preferred for transitions, reviews, cost corrections, and audit;
- money uses fixed-precision decimal values;
- tokens use integer values;
- timestamps are UTC with sub-second precision where supported;
- migrations are versioned, reviewed, forward-tested, and rollback/restore tested;
- secrets and private signing keys are never stored in ordinary tables;
- raw unbounded logs, diffs, prompts, and model outputs use protected artifact storage with digests and references;
- all writes include actor and audit metadata;
- idempotency and optimistic concurrency are explicit.

## 3. Storage Boundaries

Recommended logical boundaries:

- **Workflow store:** repositories, workflows, change requests, gates, validation, provider operations, audit.
- **Reviewer execution store:** leases, workspaces, OpenCode runs, runtime evidence, signed result metadata.
- **Usage and cost ledger:** work requests, AI requests, usage, rate cards, costs, allocations, reconciliation.
- **Artifact store:** protected logs, package manifests, diffs, validation output, reviewer output.

These may share one physical database with least-privilege schemas/roles, or use separate databases. Reviewer Service must not directly mutate workflow aggregates.

## 4. Common Columns

Every mutable business table should include equivalents of:

```text
id
created_at
created_by_actor_id
modified_at
modified_by_actor_id
row_version
```

Append-only tables use created fields and sequence/version but no in-place semantic rewrites.

## 5. Provider Configuration

### `provider_instance`

- id;
- provider_kind;
- display_name;
- base_uri;
- tenant_reference;
- mode;
- capability_version;
- capability_document;
- auth_profile_reference;
- enabled;
- audit fields.

### `provider_identity`

- id;
- provider_instance_id;
- role: Implementer, Workflow, Reviewer, Integration, Operator;
- external_identity_reference;
- credential_reference;
- permission_snapshot;
- active/rotation state.

No secret value is stored.

### `repository`

- id;
- provider_instance_id;
- provider_repository_reference;
- canonical_name;
- default_development_branch;
- default_production_branch;
- provider_mode;
- policy_binding_id;
- active.

### `provider_capability_snapshot`

- id;
- provider_instance_id;
- repository_id where repository-specific;
- version;
- observed_at;
- capability values and evidence digest.

## 6. Branch and Request Tables

### `development_branch`

- id;
- repository_id;
- branch_type;
- logical_name;
- current_provider_branch_reference;
- source_branch_reference;
- parent_development_branch_id;
- created_commit;
- current_head_commit;
- created_at;
- retired_at;
- state.

Feature branch IDs remain stable after provider rename/deletion.

### `development_branch_relation`

Represents release membership, sync-back lineage, or shared work.

### `work_request`

- id;
- development_branch_id or administrative_scope;
- workflow_run_id;
- actor_id;
- agent_session_id;
- parent_work_request_id;
- request_type;
- summary;
- protected_raw_request_reference when retained;
- status;
- received/start/end timestamps;
- idempotency key.

Every governed AI request must resolve to a WorkRequest.

### `agent_session`

- id;
- role;
- harness type/version;
- observed runtime identity;
- requested route;
- started/ended;
- host/service identity;
- parent session;
- status.

## 7. Workflow Tables

### `workflow_run`

- id;
- repository_id;
- primary_development_branch_id;
- workflow_type;
- requested_destination;
- current_phase;
- current_head_commit;
- policy_version;
- capability_snapshot_id;
- state version;
- start/end/status;
- local_finalization status.

### `workflow_transition`

Append-only:

- workflow ID;
- transition sequence;
- from/to phase;
- actor;
- reason code;
- commit;
- policy/capability version;
- evidence references;
- created at.

### `required_action`

### `blocking_condition`

### `promotion_plan`

### `promotion_step`

### `local_finalization_plan`

### `local_finalization_result`

Each plan and step is versioned and tied to expected commits.

## 8. Change Request and Provider Operation Tables

### `change_request`

- id;
- workflow_run_id;
- provider reference;
- source and target branch refs;
- head/base commits;
- state;
- provider mergeability;
- integrated commit;
- created/updated/integrated/closed times.

### `change_request_commit`

Append-only head history.

### `provider_operation`

- id;
- workflow ID;
- provider instance;
- operation type;
- idempotency key;
- request digest;
- provider object reference;
- attempt count;
- status/error category;
- scheduled/started/completed times;
- bounded response metadata.

Unique constraint on provider instance, operation type, and idempotency key.

### `provider_event_delivery`

- provider delivery ID;
- signature verification result;
- event type;
- received/processed times;
- payload digest/artifact reference;
- processing status;
- deduplication key.

## 9. Validation Tables

### `validation_requirement`

Policy-derived requirement and applicability.

### `validation_run`

- id;
- workflow/work request/session;
- requirement;
- tested commit;
- environment classification;
- command/runner;
- status;
- warning count;
- exit code;
- start/end;
- evidence digest/reference;
- freshness status.

### `validation_evidence`

Bounded structured summaries and artifact references.

## 10. Review Tables

### `review_request`

- id;
- workflow and change request;
- exact head commit;
- policy/guideline/capability versions;
- review profile;
- package digest/reference;
- status;
- created/expired/cancelled;
- current authoritative run ID.

### `review_lease`

- review request;
- lease ID;
- reviewer service instance;
- acquired/renewed/expires;
- state.

Only one active authoritative lease per review request.

### `review_run`

- id;
- review request and lease;
- reviewer agent session;
- workspace/reference;
- exact verified commit;
- runtime/profile versions;
- status;
- start/end;
- result digest;
- attestation reference;
- failure classification.

### `review_finding`

- id;
- review request;
- sequence number;
- severity/category;
- title/explanation/evidence/risk/recommendation;
- file and region;
- blocking;
- lifecycle state;
- current commit applicability;
- created/accepted/closed.

### `finding_transition`

Append-only state history.

### `discussion_binding`

- finding ID;
- provider discussion reference;
- reviewer finding message reference;
- implementation response reference;
- fix report reference;
- reviewer recheck reference;
- provider resolution snapshot;
- last reconciled at.

### `review_attestation`

- review run;
- exact commit;
- decision;
- findings digest;
- key ID;
- signature;
- signed payload digest;
- verification status/time.

Private key is never stored.

### `review_exception`

- policy rule;
- evidence;
- associated reviewed change request;
- commits;
- actor;
- provider-visible reference;
- status and invalidation.

## 11. Gate Tables

### `commit_gate`

- id;
- workflow/change request;
- commit;
- gate type;
- calculated state;
- provider gate reference;
- expected source identity;
- calculation version;
- summary/details reference;
- published/reconciled times.

### `gate_condition`

The individual facts used to calculate a gate, including validation, findings, discussions, policy, current commit, and provider rules.

## 12. AI Usage and Cost Tables

Detailed semantics are in `014_AI_USAGE_COST_AND_REPORTING.md`.

Required tables or equivalent:

- `ai_request`;
- `ai_usage_record`;
- `model_rate_card`;
- `cost_record`;
- `cost_allocation`;
- `telemetry_ingest_event`;
- `usage_reconciliation`;
- `report_export`.

Every AI request links to WorkRequest, AgentSession, DevelopmentBranch, Workflow, and role.

## 13. Audit and Configuration Tables

### `actor`

### `audit_event`

Append-only with event type, actor, target, reason, before/after digest, evidence reference, correlation IDs, and timestamp.

### `workflow_policy`

Versioned structured policy.

### `guideline_source`

Stores file/section references, hashes, and applicability metadata, not necessarily full guideline content.

### `configuration_version`

Tracks provider, reviewer profile, model route, rate card, and deployment configuration changes without secrets.

## 14. Artifact Storage

Artifacts have:

- artifact ID;
- classification;
- content digest;
- size/type;
- encrypted storage reference;
- owner/workflow/request;
- retention and legal-hold state;
- access policy;
- created/expires/deleted times.

Ordinary reports do not expose raw prompts, full source archives, secrets, or unbounded model output.

## 15. Transactions and Concurrency

Required atomic operations include:

- workflow transition plus audit;
- review lease claim;
- authoritative review result acceptance;
- finding transition plus discussion binding update;
- gate recalculation and provider-operation enqueue;
- idempotent provider operation claim;
- telemetry event ingestion/deduplication;
- cost calculation/version creation;
- allocation total validation.

Use optimistic concurrency for aggregates and database-supported locks/leases for workers.

## 16. Indexing

At minimum index:

- provider references;
- repository and active workflow;
- DevelopmentBranch ID and status;
- WorkRequest parent/session/branch;
- AIRequest time/model/role/work request;
- change-request provider reference/head;
- review request status/lease expiry;
- finding state/change request;
- gate commit/state;
- provider operation status/retry time;
- webhook delivery ID;
- audit target/time;
- reporting dimensions and timestamps.

## 17. Retention and Corrections

- workflow/audit/review decisions are long-lived according to policy;
- raw logs and review workspaces have shorter configurable retention;
- cost corrections create new versions, not destructive rewrites;
- deleting provider branches does not delete internal history;
- privacy deletion requests preserve minimum audit through redaction/pseudonymization where legally permitted;
- backups include database, configuration metadata, and required artifact indexes.

## 18. Upstream Migration Integration

Epic 1 determines the actual wshm migration system.

IDWP migrations must:

- use upstream conventions;
- avoid modifying upstream tables when an extension table is sufficient;
- include forward and upgrade tests from the pinned upstream baseline;
- survive upstream rebases;
- include data backfill and rollback/restore plans;
- record extension schema version separately from upstream version.

## 19. Acceptance Criteria

- all aggregates survive restart;
- duplicate webhooks/provider calls/telemetry are idempotent;
- wrong state version is rejected;
- lease recovery works;
- review and gate history is auditable;
- Feature Branch cost totals reconcile to request records;
- provider deletion/rename does not break internal correlation;
- backup and restore recover a workflow mid-review and mid-promotion;
- no secret appears in tables, fixtures, logs, or exports.
