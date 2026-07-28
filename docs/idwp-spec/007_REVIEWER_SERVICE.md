# Independent Development Workflow Platform - Independent Reviewer Service

**Status:** Normative reviewer specification  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

The Reviewer Service is a completely separate execution and trust boundary. It performs the intellectual review using its own OpenCode process and reports directly to Governance and the source-control provider.

The implementation harness does not launch, configure, transport, edit, or submit the independent review.

## 2. Responsibilities

The Reviewer Service MUST:

- authenticate as a reviewer service, not an implementation client;
- claim pending review jobs through a lease;
- obtain an immutable review package tied to an exact commit;
- create a fresh isolated review workspace;
- verify the checked-out commit before review;
- launch its own noninteractive OpenCode instance;
- use a versioned reviewer profile and tool restrictions;
- capture actual observed runtime/model usage;
- validate structured reviewer output;
- publish findings directly through the reviewer provider identity;
- create signed review attestations;
- submit the result to Governance;
- perform rechecks after fixes;
- preserve execution logs and costs according to retention policy;
- fail safely and release/recover leases after crashes.

## 3. Non-Responsibilities

The Reviewer Service MUST NOT:

- modify implementation code;
- commit or push source changes;
- use implementation credentials;
- merge change requests;
- change provider branch policy;
- publish the workflow gate;
- approve a commit it did not inspect;
- accept a self-reported model identity without runtime evidence;
- close a finding before verifying the fix;
- silently omit a finding from the provider conversation.

## 4. Job Lifecycle

```text
Pending
Claimed
WorkspacePreparing
Running
OutputValidating
PublishingFindings
SubmittingAttestation
Completed
RetryableFailure
PermanentFailure
Cancelled
Expired
```

### Claim and lease

A worker claims one job atomically and receives:

- review request ID;
- lease ID;
- lease expiry;
- package manifest reference;
- expected commit;
- review profile;
- provider context.

Workers renew leases during long execution. An expired lease may be reclaimed only after Governance marks the prior attempt non-authoritative.

## 5. Review Package

The package contains or references:

- repository and change-request neutral references;
- exact base and head commits;
- bounded diff manifest;
- relevant surrounding source files;
- affected code-path inventory;
- validation evidence;
- applicable guideline excerpts and policy version;
- prior findings/responses for recheck;
- architecture context;
- required output schema;
- tool and side-effect restrictions;
- package digest.

Large artifacts use authorized, expiring references. The package excludes implementation conversation history unless a specific message is required evidence.

## 6. Workspace Isolation

Each run uses a new directory or ephemeral container/VM.

Required controls:

- checkout exact head commit in detached or read-only mode;
- no write credentials in Git config;
- no implementation or workflow secrets;
- repository files treated as untrusted;
- workspace removed or quarantined after retention period;
- no reuse of implementation working copy;
- bounded disk, CPU, memory, process count, and duration;
- restricted network access;
- explicit allowed inspection tools.

The service verifies the commit before and after the review run.

## 7. OpenCode Invocation

The exact noninteractive command and telemetry interface are discovered and pinned in Epic 2.

The launcher MUST capture:

- OpenCode version;
- configuration/profile version;
- process ID and exit status;
- start and end timestamps;
- actual observed provider and model;
- input and output tokens;
- input and output cost or pricing inputs;
- retry/delegation events;
- structured result location;
- bounded stdout/stderr references;
- timeout/cancellation reason.

The Reviewer Service cannot use the same harness session ID as the implementation session.

## 8. Reviewer Prompt/Profile

The reviewer profile prioritizes:

- correctness;
- regressions;
- tests and testability;
- security;
- production safety;
- data integrity;
- concurrency;
- error handling;
- deployment/migration risk;
- provider-neutral architecture;
- applicable guideline compliance.

It avoids low-value stylistic findings unless they violate a rule or materially harm maintainability.

The profile requires a complete structured result, including an explicit no-findings result when appropriate.

## 9. Structured Result

Each finding includes:

- stable finding ID;
- severity;
- category;
- concise summary of ten words or fewer for the provider thread title;
- detailed explanation;
- evidence;
- repository-relative path and line/region where applicable;
- risk;
- recommended action;
- blocking flag;
- policy/guideline references;
- confidence and limitations.

The run also includes:

- reviewed commit;
- decision;
- files/scope inspected;
- runtime identity;
- prompt/profile version;
- start/end;
- package digest;
- usage/cost references.

## 10. Provider Publication

The Reviewer Service publishes directly through the reviewer provider identity.

For each finding:

1. create `Code Review NNN: <summary>` discussion;
2. publish explanation, evidence, location, risk, and recommendation;
3. store provider discussion and message references;
4. submit formal changes-required decision when supported and blocking findings exist.

For no findings:

- publish an auditable no-findings review summary;
- identify reviewed commit and scope;
- submit approval when supported;
- bind the provider review to the attestation.

Provider publication must occur before Governance accepts the review as complete.

## 11. Recheck

A recheck package contains:

- original finding;
- original evidence;
- implementation response;
- fix explanation;
- new commit diff relevant to the finding;
- validation evidence;
- exact current head.

The Reviewer Service launches a fresh OpenCode session. It posts in the same provider discussion:

- `Reviewer Recheck: Accepted`; or
- `Reviewer Recheck: Not Accepted` with new evidence.

Only accepted recheck allows the finding to become Accepted/Closed.

## 12. Signed Attestation

After provider publication, the service signs a canonical result digest.

Governance verifies:

- key ID and signature;
- authenticated reviewer service;
- active review request/lease;
- package digest;
- exact commit;
- provider publication references;
- result schema and lifecycle.

Keys are rotated and revocable. A revoked key invalidates untrusted future submissions but does not silently rewrite historical accepted records.

## 13. Usage and Cost

Every reviewer OpenCode model call is recorded as an AIRequest correlated to:

- reviewer WorkRequest;
- ReviewRun;
- WorkflowRun;
- DevelopmentBranch/Feature Branch ID;
- model/provider;
- input/output tokens;
- input/output cost;
- total cost and currency;
- telemetry provenance and quality.

Retries and failed calls are retained.

## 14. Failure Handling

### OpenCode timeout

Terminate the process group, preserve bounded diagnostics, mark retryable/permanent by policy, and do not publish approval.

### Malformed output

Attempt a bounded schema-repair run only when policy permits. Record additional cost. Never infer an approval.

### Provider publication failure

Do not submit an authoritative attestation until provider publication succeeds or a documented provider-equivalent record is created.

### Wrong commit

Reject immediately, destroy/quarantine workspace, and request a fresh package.

### Service crash

Lease expires; another worker may reclaim after reconciliation. Duplicate provider publication is prevented through idempotency and provider-reference checks.

### Model unavailable

Retry with the same approved route or use a policy-approved fallback. Record requested and actual model. Do not silently downgrade to an unapproved model.

## 15. Administration

Protected reviewer administration provides:

- job queue and lease status;
- run details and logs;
- runtime/model usage;
- failures and retry actions;
- signing-key status;
- OpenCode configuration health;
- workspace cleanup status;
- provider identity health.

Implementation identities have no access.

## 16. Acceptance Criteria

The Reviewer Service is acceptable when:

- it runs under a separate OS/container identity;
- implementation cannot access its credentials or submission endpoint;
- it launches an independent OpenCode instance;
- it cannot push code;
- it publishes findings directly to the provider;
- it signs exact-commit attestations;
- Governance rejects stale, unsigned, duplicate, or wrong-session results;
- rechecks use fresh sessions and same provider discussion;
- usage and cost are captured per request;
- crash/retry tests do not duplicate authoritative findings.
