# Independent Development Workflow Platform - Provider Adapter Roadmap

**Status:** Normative roadmap and design constraints  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

This document ensures that adopting wshm does not create a permanent GitHub dependency.

GitHub is the first fully enforced provider because it is the immediate operating target. The architecture must also support Azure DevOps, GitLab, Gitea, Bitbucket, and controlled local Git without rewriting workflow policy, reviewer logic, cost accounting, or MCP contracts.

## 2. Delivery Order

### Phase 1 - GitHub production adapter

Deliver and prove the complete workflow on GitHub, including identities, protected branches/rulesets, required gate, provider-visible review discussions, exact-head invalidation, integration, release, sync-back, and cleanup.

### Phase 2 - Normalize verified wshm adapters

Inventory and wrap any upstream GitLab and Gitea support behind the IDWP provider contract. Classify each capability as Enforced, Equivalent, Advisory, or Unsupported.

### Phase 3 - Azure DevOps

Implement Azure Repos pull requests, branch policies/statuses, service hooks, thread replies/status mapping, service identities, and provider administration.

### Phase 4 - Bitbucket

Implement Bitbucket Cloud and Bitbucket Data Center/Server separately.

### Phase 5 - Generic self-hosted Git

Support controlled bare repositories and server-side hooks. Add or integrate an IDWP collaboration surface when no forge exists.

## 3. Capability Matrix

The exact values must be verified during adapter implementation.

| Capability | GitHub | GitLab | Gitea | Azure DevOps | Bitbucket | Local Git |
|---|---|---|---|---|---|---|
| Change request | Expected | Verify upstream | Verify upstream | Planned | Planned | Requires IDWP/forge |
| Inline findings | Expected | Verify | Verify | Planned | Planned | Requires IDWP/forge |
| Replies/discussions | Expected | Verify | Verify | Planned | Planned | Requires IDWP/forge |
| Resolution state | Expected | Verify | Verify | Planned | Planned | Requires IDWP/forge |
| Required gate/status | Expected | Verify | Verify | Planned | Planned | Hook/equivalent |
| Protected branch policy | Expected | Verify | Verify | Planned | Planned | Server permissions/hooks |
| Service identities | Apps | Tokens/apps verify | Tokens/apps verify | Service principal/PAT | OAuth/apps/tokens | OS/signing identities |
| Signed webhooks | Expected | Verify | Verify | Service hooks verify | Verify | N/A/hooks |
| Auto-merge/queue | Expected/verify | Verify | Verify | Planned | Planned | IDWP integrator |

The table is not an implementation claim. Adapter conformance evidence is authoritative.

## 4. GitHub Adapter Requirements

- separate implementer, workflow, reviewer, and optional integration identities;
- selected-repository least privilege;
- protected development and production branches;
- required IDWP gate from expected identity;
- stale review invalidation;
- required conversation resolution where available;
- no force push/deletion;
- branch policy inventory, plan, apply, verify, and rollback;
- review finding/reply/recheck mapping;
- webhook signature and delivery deduplication;
- periodic reconciliation;
- auto-merge or constrained integration after gates;
- sandbox end-to-end bypass tests.

GitHub-specific administration remains outside the core workflow crate.

## 5. GitLab/Gitea Normalization

Do not assume existing wshm support satisfies IDWP semantics.

For each upstream adapter:

1. identify current capabilities and credential model;
2. wrap types behind neutral traits;
3. add discussion and gate mapping;
4. add policy inspection;
5. add exact-head review invalidation;
6. add provider conformance tests;
7. classify enforcement mode;
8. document gaps without weakening core policy.

## 6. Azure DevOps Design

Expected mappings:

| Neutral concept | Azure DevOps concept |
|---|---|
| Repository | Azure Repos repository |
| ChangeRequest | Pull request |
| ReviewDiscussion | PR thread/comment |
| Discussion resolution | Thread status and replies |
| Review decision | Vote/status plus IDWP gate |
| CommitGate | Branch policy/status/check/build validation |
| ProviderEvent | Service hook |
| ProviderIdentity | Service principal, managed identity, or PAT-backed service identity |
| BranchPolicy | Azure Repos branch policy |

Important differences:

- thread status semantics differ from GitHub;
- vote/approval behavior differs;
- authentication and token rotation differ;
- merge completion and policy evaluation differ;
- Markdown and API payload behavior differ;
- organization/project/repository scoping differs.

These differences stay in the Azure adapter.

## 7. Bitbucket Design

Cloud and Data Center have separate APIs and operational models.

Evaluate:

- pull-request tasks versus comments;
- approval and default reviewer requirements;
- build statuses and merge checks;
- branch permissions;
- application passwords/OAuth/access tokens;
- webhook signatures and delivery IDs;
- merge strategies;
- server plugin or hook requirements for stronger enforcement.

## 8. Local Git Design

### Minimum adapter

- inspect repository and refs;
- compare commits;
- create/delete branches where authorized;
- identify ancestry;
- create signed provider-operation records.

### Enforced central repository option

A production-capable local provider requires:

- central bare repository owned by integration service;
- implementation actors denied direct protected-ref writes;
- pre-receive hooks querying IDWP gate and expected commit;
- signed integration operation;
- durable IDWP change-request/discussion UI or an attached forge;
- audit and webhook/hook event ingestion;
- protected backups and access control.

Without these controls, mode is Advisory.

## 9. Provider Migration

Repository migration between providers must preserve:

- internal Repository ID;
- DevelopmentBranch IDs;
- Workflow and WorkRequest history;
- AI usage/cost attribution;
- review findings and provider discussion archive references;
- old and new provider references;
- audit trail;
- policy classification.

Active workflows should normally be completed or paused before migration. Cross-provider in-flight migration requires a specific runbook.

## 10. Adapter SDK and Test Kit

Provide an internal adapter SDK with:

- neutral Rust traits and DTOs;
- capability declaration helpers;
- webhook normalization framework;
- idempotency helpers;
- provider-reference types;
- test fixtures;
- conformance test runner;
- sandbox test harness;
- documentation template.

## 11. Release Gate

A new adapter cannot be labeled production-enforced until:

- conformance tests pass;
- security permissions are reviewed;
- exact-head invalidation works;
- provider-visible finding lifecycle works;
- required gate cannot be spoofed by implementation identity;
- protected branch policy is verified;
- duplicate/reordered events are safe;
- end-to-end feature and production promotion pass;
- failure/recovery and rollback are documented;
- independent review accepts the adapter.
