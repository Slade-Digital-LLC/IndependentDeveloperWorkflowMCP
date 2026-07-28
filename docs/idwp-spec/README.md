# Independent Development Workflow Platform Specification

**Architecture baseline:** wshm-based, provider-neutral governance platform  
**Specification version:** 2.0  
**Date:** 2026-07-27

## Decision Summary

The platform will be built by adopting and extending the SSPL-licensed Rust project **wshm** rather than creating a new LAMP application from scratch.

The adoption is intentionally not GitHub-specific. GitHub is the first production provider, but all workflow policy, review state, cost accounting, and MCP contracts must use provider-neutral concepts. Existing or future adapters may target GitHub, GitLab, Gitea, Azure DevOps, Bitbucket Cloud, Bitbucket Data Center, another hosted forge, or a locally hosted Git service.

The exact upstream repository, version, license text, dependencies, database, UI stack, provider support, and extension seams must be verified and pinned during Epic 1. No implementation may rely on an unverified upstream assumption.

## Document Map

| Document | Purpose |
|---|---|
| `000_ADOPTION_DECISION.md` | Records why wshm was selected and the accepted tradeoffs. |
| `001_VISION.md` | Defines product goals, scope, and success measures. |
| `002_ARCHITECTURE.md` | Defines components, boundaries, extension strategy, and deployment model. |
| `003_DOMAIN_MODEL.md` | Defines provider-neutral domain concepts and invariants. |
| `004_WORKFLOW_STATE_MACHINE.md` | Defines feature, review, promotion, and sync-back states. |
| `005_SECURITY_MODEL.md` | Defines trust boundaries, identities, threats, and enforcement. |
| `006_SOURCE_CONTROL_PROVIDER_CONTRACT.md` | Defines the generic source-control and forge adapter contract. |
| `007_REVIEWER_SERVICE.md` | Defines the isolated reviewer service and its OpenCode runtime. |
| `008_MCP_PROTOCOL.md` | Defines implementation-side MCP tools and reviewer-only APIs. |
| `009_SEQUENCE_DIAGRAMS.md` | Shows normal and exceptional end-to-end interactions. |
| `010_PERSISTENCE_MODEL.md` | Defines logical persistence, correlation, and migration requirements. |
| `011_DEPLOYMENT.md` | Defines deployment, isolation, operations, and upstream upgrades. |
| `012_PROVIDER_ADAPTER_ROADMAP.md` | Defines GitHub-first delivery and future provider plans. |
| `013_FAILURE_MODES.md` | Defines detection, blocking, retry, and recovery behavior. |
| `014_AI_USAGE_COST_AND_REPORTING.md` | Defines per-request tokens, costs, logs, and reporting. |
| `015_GUIDELINE_TRANSLATION.md` | Maps the original guidelines into Rust/wshm implementation rules. |
| `IMPLEMENTATION_PLAN.md` | Breaks implementation into independently assignable epics. |

## How to Use This Specification

A coding agent should be instructed with a bounded command such as:

```text
Implement Epic 1 from IMPLEMENTATION_PLAN.md.
```

The agent must read the epic, all cited documents, repository `AGENTS.md`, applicable guidelines, and project-specific guidance before changing files. It must stop at the epic boundary.

## Normative Language

`MUST`, `MUST NOT`, `REQUIRED`, `SHOULD`, and `MAY` are normative. When an upstream wshm constraint conflicts with a requirement, the implementation must either:

1. adapt wshm without weakening the requirement;
2. document a provider or upstream limitation and fail closed; or
3. request an explicit architecture decision.

Convenience is not a reason to weaken separation of duties, review integrity, cost accuracy, or protected-branch enforcement.
