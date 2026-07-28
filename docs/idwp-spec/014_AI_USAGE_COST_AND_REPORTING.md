# Independent Development Workflow Platform - AI Usage, Cost Accounting, Logs, and Reporting

**Status:** Normative accounting and reporting specification  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

IDWP must account for every observable AI model request made during implementation, delegation, independent review, recheck, validation assistance, promotion, and workflow administration.

The system must answer:

- which model/provider actually ran;
- input and output tokens;
- input cost, output cost, and total cost;
- which WorkRequest caused the call;
- which implementation/reviewer session issued it;
- which workflow and Feature Branch ID it belongs to;
- total cost per feature, repository, provider, role, model, stage, and time period;
- whether telemetry and cost are complete and reconciled;
- which logs, commits, reviews, and provider operations correlate to the request.

## 2. Required Accounting Hierarchy

```text
Repository
  -> DevelopmentBranch / Feature Branch ID
      -> WorkflowRun
          -> WorkRequest
              -> AgentSession
                  -> AIRequest attempt
                      -> UsageRecord
                      -> CostRecord version
                      -> CostAllocation
```

Every governed file-changing WorkRequest must have a DevelopmentBranch ID. Every AIRequest must have a WorkRequest.

## 3. AIRequest Required Fields

- stable AIRequest ID;
- WorkRequest ID;
- Workflow ID;
- DevelopmentBranch/Feature Branch ID;
- repository;
- role: Implementation, DelegatedImplementation, IndependentReview, Recheck, WorkflowAssistance, Other;
- AgentSession ID;
- parent AIRequest when delegated/retried;
- harness/runtime and version;
- requested provider/model/route;
- actual observed provider/model/route;
- request attempt number;
- start/end/duration;
- status: Completed, Failed, Cancelled, TimedOut, Unknown;
- input tokens;
- output tokens;
- cached input/output, reasoning, tool, or other token classes when available;
- input cost;
- output cost;
- other cost;
- total cost;
- currency;
- cost source;
- telemetry quality;
- raw telemetry digest/reference;
- prompt/output retention classification;
- error/fallback metadata;
- created/audit fields.

Retries and delegated calls are separate rows.

## 4. Telemetry Sources

Preferred order:

1. machine-readable OpenCode request/event/plugin/API telemetry;
2. model provider response usage and cost;
3. wshm agent execution telemetry;
4. approved deterministic rate-card calculation from known tokens;
5. protected log parsing only as a documented fallback.

The model's natural-language statement of tokens or cost is never authoritative.

Epic 2 must identify the exact pinned OpenCode and wshm interfaces and prove automatic collection for implementation and reviewer processes.

## 5. Actual Model Tracking

Store both requested and actual observed route.

Examples that must be visible:

- a delegated task intended for one model but executed by another;
- provider fallback;
- alias resolution;
- retries across models;
- reviewer recheck using a different approved model;
- unknown actual model due to incomplete telemetry.

Policy may reject unapproved actual routes even when the call succeeded.

## 6. Cost Calculation

### Source precedence

1. provider/OpenCode-reported final cost with trustworthy provenance;
2. wshm runtime cost calculated from a pinned rate configuration;
3. IDWP rate-card calculation from exact token categories;
4. Unpriced/Unavailable.

### Rate cards

Rate cards are effective-dated and versioned by:

- provider;
- model/route;
- input token class;
- output token class;
- cached/reasoning/other pricing;
- currency;
- unit size;
- effective start/end;
- source and approval.

Historical cost is not silently recalculated. Corrections create new CostRecord versions and audit events.

### Precision

Use integers for tokens and fixed-precision decimal for money. Never use floating-point money.

### Unknown cost

Unknown, unpriced, incomplete, or unreconciled cost must never display as zero.

## 7. Feature Branch Attribution

The internal DevelopmentBranch ID is authoritative, not the provider branch name.

Rules:

- implementation and review calls for a feature are directly attributed to its Feature Branch ID;
- fix requests inherit the finding/workflow branch;
- rechecks inherit the reviewed branch;
- single-feature release/promotion costs may be directly allocated to that feature;
- multi-feature release costs use an explicit allocation method;
- shared infrastructure/admin work may remain unallocated or use an approved cost center;
- one cost record cannot be counted in full more than once.

Supported allocation methods:

- Direct;
- EqualShare;
- WeightedByPriorFeatureCost;
- WeightedByChangedLines or another approved measure;
- ManualApproved;
- UnallocatedShared.

Allocation method and version are visible in reports.

## 8. Work Request Capture

WorkRequest records include:

- normalized request summary/type;
- originating user/service;
- implementation or reviewer role;
- branch/workflow;
- parent/delegation relationship;
- start/end/status;
- protected raw prompt reference only when retention is approved;
- total tokens/cost derived from AIRequests;
- associated commits, validation, change requests, findings, and provider operations.

A user command such as `sync this code to master` is one WorkRequest that may create child requests for review, fixes, release review, and local finalization while retaining the top-level correlation.

## 9. Telemetry Ingestion

Telemetry API/event ingestion requires:

- authenticated harness/service identity;
- event/request ID;
- WorkRequest/AgentSession correlation;
- timestamps;
- model/usage/cost fields;
- raw digest/reference;
- schema version;
- idempotency key.

The ingest pipeline:

1. validates schema and identity;
2. deduplicates;
3. resolves branch/workflow correlation;
4. stores raw normalized event;
5. creates/updates AIRequest attempt;
6. calculates or validates cost;
7. flags quality/reconciliation issues;
8. updates reporting aggregates asynchronously.

Do not reject valid workflow completion solely because provider cost is temporarily unavailable; mark accounting incomplete and alert according to policy.

## 10. Reconciliation

Reconcile:

- OpenCode sessions to wshm agent runs;
- reviewer OpenCode telemetry to ReviewRuns;
- provider usage summaries where available;
- AIRequest attempts to WorkRequests;
- cost records to tokens/rate cards;
- feature allocations to 100 percent of allocatable cost;
- reporting aggregates to base rows.

Quality states:

- Complete;
- Calculated;
- Partial;
- Unpriced;
- Unavailable;
- Unreconciled;
- Corrected.

## 11. Reporting Web Application

Extend the wshm dashboard with protected IDWP reporting.

### 11.1 Executive dashboard

Show:

- total cost and tokens for selected period;
- cost by repository and Feature Branch ID;
- implementation versus independent review;
- model/provider distribution;
- trend by day/week/month;
- active feature projected/current cost;
- telemetry completeness;
- unreconciled/unpriced cost;
- top expensive requests/features;
- review cost as percentage of feature cost;
- workflow success/failure and cycle time.

### 11.2 Feature Branch report

For one Feature Branch ID:

- names and provider refs over time;
- repository and workflow status;
- user/work requests;
- child/delegated requests;
- AIRequests with actual models;
- tokens and cost by role/model/stage;
- validation, commits, change requests, findings, reviews, release/promotion steps;
- allocated shared cost and method;
- total direct, allocated, unallocated-related, and combined cost;
- telemetry quality and reconciliation;
- correlated logs/timeline.

### 11.3 Work Request detail

- request hierarchy;
- harness/session;
- branch/workflow;
- model attempts/retries;
- input/output token/cost components;
- errors/fallbacks;
- associated files/commits/validation/findings;
- logs and evidence subject to authorization.

### 11.4 AIRequest detail

- requested versus actual model;
- complete token categories;
- cost source/rate card/version;
- raw telemetry digest/reference;
- timing/status/error;
- parent/delegation;
- role and stage;
- correction history.

### 11.5 Logs

Search/filter by:

- time range;
- repository;
- provider;
- branch/Feature Branch ID;
- workflow/WorkRequest/AIRequest;
- implementation/reviewer session;
- change request/review/finding;
- model;
- severity/error category;
- provider delivery/operation;
- correlation ID.

Logs are structured and redacted. Raw sensitive artifacts require separate privileged access and auditing.

### 11.6 Filters and comparisons

- repository/provider;
- feature/release/hotfix;
- actor/role;
- model/provider route;
- workflow stage;
- status;
- telemetry quality;
- currency;
- date range;
- review required/exception;
- success/failure.

Support feature-to-feature and model-to-model comparison without misleading mixed-currency totals.

### 11.7 Exports

Authorized CSV and JSON export must:

- use exact decimal text;
- include currency, cost source, quality, rate-card version, and allocation method;
- preserve internal IDs and selected provider references;
- record who exported, filter criteria, time, and row count;
- redact protected prompt/output/log data by default.

### 11.8 Accessibility

- WCAG 2.2 AA;
- keyboard operable;
- semantic tables;
- visible focus;
- non-color-only status;
- accessible chart data tables;
- readable dense operational layouts;
- full error details appropriate for helpdesk without secrets.

## 12. Reporting APIs

Provide paged, filterable APIs for:

- branch summaries;
- WorkRequests;
- AIRequests;
- model usage;
- cost totals and trends;
- review/implementation split;
- allocations;
- reconciliation issues;
- correlated logs;
- exports.

Authorization applies at organization/repository/report sensitivity level.

## 13. Privacy and Retention

Default ordinary accounting stores metadata, token counts, cost, hashes, and references rather than raw prompts/output.

When raw content is retained:

- classify and encrypt;
- restrict access;
- audit reads;
- apply retention/expiration;
- exclude secrets and unnecessary source content;
- support legal/privacy requirements.

## 14. Accounting Tests

Test:

- one WorkRequest with many model calls;
- retries and failed calls;
- delegated model route mismatch;
- reviewer and recheck costs;
- branch rename/deletion;
- single/multi-feature release allocation;
- duplicate/missing/conflicting telemetry;
- rate-card changes/corrections;
- mixed currency;
- unknown cost display;
- aggregate-to-detail reconciliation;
- export precision and authorization;
- dashboard accessibility;
- log redaction.

## 15. Acceptance Criteria

- every observed model call is stored separately;
- actual model/provider is visible or explicitly unknown;
- input/output tokens and costs are stored with provenance;
- every governed request is linked to a stable Feature Branch ID or explicit administrative scope;
- total feature cost reconciles without double counting;
- reviewer cost is distinguishable from implementation cost;
- dashboard and APIs provide detailed logs/cost drill-down;
- incomplete data is visibly labeled;
- exports are exact, authorized, and audited;
- upstream wshm upgrades do not break telemetry contract without compatibility failure.
