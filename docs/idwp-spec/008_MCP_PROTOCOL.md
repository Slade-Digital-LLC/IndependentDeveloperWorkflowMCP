# Independent Development Workflow Platform - MCP Protocol

**Status:** Normative MCP/API contract  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

The MCP interface allows an implementation harness such as OpenCode to request governed outcomes without receiving raw provider credentials or reimplementing workflow policy.

The tool surface is small, provider-neutral, authenticated, and state-oriented.

## 2. Transport

Use MCP Streamable HTTP over TLS unless the pinned OpenCode and Rust MCP SDK combination requires a documented alternative.

The exact SDK and client compatibility are proven in Epic 2.

## 3. Authentication and Authorization

Every MCP client has:

- client/service identity;
- actor identity;
- organization/repository scope;
- allowed tool set;
- implementation session ID;
- expiration and rotation policy.

Reviewer-result submission is not available to implementation MCP clients.

## 4. Common Response Envelope

Mutation and status tools return:

```json
{
  "workflowId": "uuid",
  "stateVersion": 17,
  "phase": "IndependentReviewRequired",
  "requiredActions": [],
  "allowedActions": [],
  "blockingConditions": [],
  "nextAction": "workflow_request_review",
  "providerMode": "Enforced",
  "evidenceReferences": []
}
```

Large details use resources or authorized paged APIs.

## 5. Implementation-Side Tools

### `workflow_start`

Starts or resumes a workflow.

Inputs:

- provider-neutral repository reference;
- optional provider hint;
- local workspace metadata;
- request summary/type;
- implementation session ID;
- requested destination such as Development or Production;
- idempotency key.

Behavior:

- resolve repository and provider capabilities;
- record WorkRequest;
- create/resolve DevelopmentBranch ID;
- classify feature/release/hotfix/administrative work;
- create or resume workflow and promotion plan;
- return required bootstrap actions.

### `workflow_status`

Returns compact authoritative state, commits, change requests, validation, review, promotion, cost summary, required actions, and blockers.

### `workflow_record_work_request`

Records follow-up/delegated requests such as fixing a finding. It requires parent WorkRequest and branch/workflow correlation.

### `workflow_record_validation`

Records validation evidence tied to a commit.

Required input:

- workflow and WorkRequest IDs;
- validation requirement/command identifier;
- environment;
- tested commit;
- status and warning count;
- timestamps;
- evidence digest/reference;
- harness session;
- idempotency key.

A simple unsubstantiated boolean is insufficient.

### `workflow_prepare_commit`

Confirms that committing is allowed and returns branch, scope, and validation constraints. The local harness normally performs the local commit.

### `workflow_register_push`

Verifies and records remote source branch/head after push.

### `workflow_create_change_request`

Creates or updates the provider-neutral change request through the adapter. It derives target, description, gates, and review requirements from policy.

### `workflow_request_review`

Creates an immutable ReviewRequest and places a job in the independent reviewer queue. The implementation client cannot submit the result.

### `workflow_list_findings`

Returns compact finding states and provider discussion references.

### `workflow_respond_to_finding`

Posts the implementation response in the same provider discussion through the implementation identity or verifies an existing authorized response.

Inputs:

- finding ID;
- decision: Accepted, AcceptedWithConditions, Rejected;
- rationale;
- state version;
- idempotency key.

### `workflow_report_fix`

Posts fix details and validation summary in the same discussion. It does not close the finding.

### `workflow_request_recheck`

Creates a recheck job after verifying a new current head and fresh validation.

### `workflow_complete_change_request`

Attempts or enables integration only when all workflow and provider gates pass.

### `workflow_promote`

Creates/resumes the complete promotion plan. A production destination includes release and sync-back steps.

### `workflow_finalize_local`

Records local fetch/prune/checkout/clean evidence after remote completion.

### `workflow_cancel`

Cancels when authorized and safe. Returns retained artifacts and local safety instructions.

## 6. Read-Only Resources

Representative resources:

```text
idwp://workflow/{workflowId}
idwp://workflow/{workflowId}/timeline
idwp://workflow/{workflowId}/validation
idwp://workflow/{workflowId}/reviews
idwp://review/{reviewRequestId}/package-manifest
idwp://finding/{findingId}
idwp://branch/{developmentBranchId}/cost-summary
idwp://request/{workRequestId}/ai-requests
idwp://provider/{providerInstanceId}/capabilities
```

Resources are paged, authorized, and redact sensitive content.

## 7. Reviewer-Only Service API

The Reviewer Service uses a separate authenticated interface, not implementation tools.

Representative operations:

- `review_claim_next`;
- `review_renew_lease`;
- `review_get_package`;
- `review_submit_attestation`;
- `review_report_failure`;
- `review_release_lease`.

Only reviewer service credentials may call them.

## 8. Provider-Neutral Contract

MCP inputs and outputs use internal IDs and neutral destinations such as:

- Development;
- Production;
- SyncBack;
- ChangeRequest;
- Discussion;
- Gate.

Provider-specific URLs and references may be returned as opaque navigation metadata, not required business fields.

## 9. Error Model

Errors contain:

- stable error code;
- human-readable message;
- retry classification;
- current state/version when relevant;
- blocking conditions;
- evidence reference;
- no secrets.

Representative codes:

- `IDWP_CONFLICT_STATE_VERSION`;
- `IDWP_VALIDATION_STALE`;
- `IDWP_REVIEW_REQUIRED`;
- `IDWP_REVIEW_STALE`;
- `IDWP_FINDING_OPEN`;
- `IDWP_PROVIDER_CAPABILITY_UNAVAILABLE`;
- `IDWP_PROVIDER_POLICY_DRIFT`;
- `IDWP_UNAUTHORIZED_ACTOR`;
- `IDWP_WRONG_COMMIT`;
- `IDWP_LOCAL_FINALIZATION_REQUIRED`;
- `IDWP_TELEMETRY_INCOMPLETE`.

## 10. Idempotency and Concurrency

Every mutation accepts an idempotency key and expected state version. Duplicate calls return the original result or current equivalent.

The server rejects stale state changes with the current version and safe next action.

## 11. Token and Context Efficiency

Tool descriptions are concise. Tools return summaries rather than full logs/diffs/guideline files. The harness requests details only when needed.

Guideline applicability returns:

- file/section reference;
- applicability reason;
- concise rule summary;
- evidence URI.

Critical rules are deterministic policy, not retrieved probabilistically.

## 12. OpenCode Bootstrap Guidance

Repository `AGENTS.md` should contain concise wording equivalent to:

```markdown
## Governed Development Workflow

For file-changing work, begin with `workflow_start` from the configured IDWP
MCP server and use the returned workflow ID for all governed operations.

Treat required actions, allowed actions, blockers, validation state, review
state, and next action as authoritative. Do not bypass protected integration,
independent review, required provider discussions, promotion, sync-back, or
local finalization.

When review is required, call `workflow_request_review`. The separate Reviewer
Service performs and publishes the review. The implementation session must not
submit or impersonate reviewer results.

A request to sync or promote to production authorizes the complete policy path,
including development integration, release, production integration, sync-back,
cleanup, and final restoration to a clean current development branch.
```

Exact tool names are generated from the implemented MCP schema.

## 13. Compatibility Tests

Prove with the pinned OpenCode client:

- initialize;
- tool discovery;
- authenticated calls;
- resources and pagination;
- long-running workflow polling;
- errors and retries;
- state version conflicts;
- process/client restart;
- no dependence on in-memory MCP session state;
- representative payload size and redaction.
