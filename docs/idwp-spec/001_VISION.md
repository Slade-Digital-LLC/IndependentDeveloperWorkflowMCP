# Independent Development Workflow Platform - Vision

**Status:** Normative product vision  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Mission

IDWP makes AI-assisted software development governable, auditable, provider-neutral, and resistant to self-approval.

An implementation agent may write code and propose changes, but it cannot independently decide that its own work is safe to integrate. A separate reviewer service, source-control enforcement, and an authoritative workflow state machine determine whether work may advance.

## 2. User Experience

The user issues a high-level request such as:

```text
Sync this code to master.
```

The implementation agent calls IDWP through MCP. IDWP expands the request into the complete governed workflow, including:

1. identify or create the feature branch lineage;
2. verify validation evidence;
3. create or update the change request into `develop`;
4. request independent review;
5. stop for findings and require visible PR/MR discussion;
6. require fixes, fresh validation, and reviewer recheck;
7. integrate into `develop`;
8. create a release branch when policy requires it;
9. open and complete the production change request into `master`;
10. synchronize `master` back into `develop` through a change request;
11. clean up eligible remote branches;
12. instruct the implementation harness to fetch, prune, check out `develop`, and verify a clean local state;
13. record all work requests, model calls, tokens, costs, logs, reviews, and provider operations.

The original user request authorizes the routine intermediate steps. Findings suspend the workflow but do not cancel the original promotion intent.

## 3. Core Outcomes

The system MUST provide:

- separation of implementation, review, workflow, and integration authority;
- provider-enforced protected branch behavior where supported;
- a reviewer that runs in its own service and its own OpenCode context;
- review findings and responses visible on the change request itself;
- review approval tied to the exact current commit;
- automatic invalidation after any new commit;
- deterministic feature, release, hotfix, production, and sync-back workflows;
- stable Feature Branch IDs independent of provider branch names;
- per-work-request and per-model-request token and cost accounting;
- detailed web reporting for workflows, reviews, logs, tokens, and costs;
- provider-neutral contracts for future forges and local Git;
- durable, restart-safe, idempotent operation;
- full auditability without exposing secrets or raw private prompts by default.

## 4. Product Principles

### Enforce, do not merely instruct

Critical controls must exist in the workflow engine and source-control provider configuration. Agent prompt text alone is not an enforcement boundary.

### Independent means operationally separate

The reviewer has a separate service identity, process, OpenCode instance, model configuration, workspace, source-control identity, credentials, and audit trail.

### The change request is the visible review record

Each finding, implementation response, fix report, disagreement, recheck, and acceptance must be visible in the provider's change-request discussion. The database remains the enforcement record, but private-only review discussion is insufficient.

### Current commit or no approval

A review result is valid only for the exact head commit it inspected. New commits invalidate the result and the passing gate.

### Provider-neutral domain, provider-specific enforcement

The domain expresses intent. Adapters translate intent into GitHub, GitLab, Gitea, Azure DevOps, Bitbucket, or local-server mechanisms.

### Upstream before reinvention

Use wshm capabilities where they satisfy requirements. Extend or patch only where governance, independence, telemetry, or provider neutrality requires it.

### Cost is part of the work product

Every model invocation must be correlated to the work request and feature branch that caused it. Unknown cost is reported as unknown, never silently treated as zero.

## 5. Actors

- **Human User:** requests work and may make explicit exception decisions.
- **Implementation Harness:** usually OpenCode; edits code and responds to findings.
- **Workflow Service:** authoritative state machine, MCP server, gate publisher, and promotion coordinator.
- **Reviewer Service:** claims review jobs, launches isolated reviewer OpenCode, and publishes review decisions.
- **Integration Mechanism:** merges only after required provider and workflow gates pass.
- **Operator:** administers policy, providers, rate cards, deployment, and incident recovery.
- **Source-Control Provider:** hosts repositories and, when supported, change requests, discussions, branch policies, and commit gates.

## 6. Version 1 Scope

Version 1 includes:

- wshm fork and extension framework;
- GitHub as the first fully enforced provider;
- provider-neutral contracts and conformance tests;
- preservation or normalization of verified upstream GitLab/Gitea support where practical;
- independent reviewer service using its own OpenCode instance;
- MCP access for the implementation harness;
- feature/develop/release/master/sync-back workflow;
- validation and review gates;
- per-request usage and cost accounting;
- administrative reporting web application;
- deployment, backup, recovery, and upstream maintenance.

## 7. Deferred Scope

Deferred but architecturally anticipated:

- production Azure DevOps adapter;
- production Bitbucket Cloud and Data Center adapters;
- advanced local-Git enforcement through server-side hooks;
- additional AI harnesses beyond OpenCode;
- cross-organization federation;
- automated billing or chargeback;
- SaaS multi-tenancy.

## 8. Success Measures

A pilot is successful when:

- the implementation identity cannot push or merge around the required workflow;
- a reviewer finding creates a visible provider discussion and blocks integration;
- a new commit invalidates approval;
- a recheck by the separate reviewer permits integration only after acceptance;
- `sync to master` completes the entire promotion and sync-back sequence;
- the local harness ends on current, clean `develop`;
- every AI request has model, token, cost-quality, workflow, and feature correlation;
- the reporting UI reconciles feature totals to underlying requests;
- adapter conformance tests contain no GitHub-specific domain dependency;
- upstream updates can be evaluated without rewriting IDWP-owned modules.
