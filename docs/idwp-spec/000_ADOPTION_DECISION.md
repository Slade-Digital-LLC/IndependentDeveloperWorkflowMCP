# Architecture Decision: Adopt wshm as the Upstream Foundation

**Status:** Accepted  
**Decision ID:** ADR-000  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Context

The original design proposed a new workflow platform implemented as a LAMP application. Further analysis identified wshm as a closer foundation because it already targets self-hosted repository automation, agent execution, pull-request review, fix loops, merge automation, and a web dashboard.

Building all of those capabilities again would create unnecessary implementation and security risk. The owner accepts Rust and the SSPL license as reasonable tradeoffs.

At the same time, the platform must not become dependent on GitHub. The organization expects to support Azure DevOps later and may also need GitLab, Gitea, Bitbucket, or locally hosted Git systems.

## 2. Decision

Adopt wshm as the upstream runtime and repository-automation foundation.

The resulting product is the **Independent Development Workflow Platform (IDWP)**, implemented as a maintained wshm fork plus extension crates, migrations, provider adapters, dashboard modules, and deployment assets.

The implementation MUST:

- preserve wshm functionality that materially reduces custom work;
- keep the fork shallow and upstream-compatible;
- add provider-neutral governance rather than embedding GitHub rules in core logic;
- add an MCP interface for implementation agents;
- add a completely independent reviewer service that launches its own OpenCode instance;
- add branch/work-request/AI-request accounting and detailed reporting;
- add strict review-conversation and current-commit enforcement;
- retain the full feature-to-develop-to-master-to-develop workflow;
- preserve the spirit of the existing check-in, implementation-plan, testing, documentation, and security guidelines.

## 3. Accepted Tradeoffs

The following are explicitly accepted:

- Rust replaces the proposed PHP/Symfony implementation.
- wshm's existing frontend, persistence, queue, and deployment technologies should be retained unless an extension requirement proves them unsuitable.
- SSPL-1.0 licensing is accepted for this project, subject to exact upstream verification and continuing compliance.
- A maintained fork may be required when extension points are insufficient.
- Upstream rebases and compatibility testing become ongoing operational work.

## 4. Conditions of Adoption

Epic 1 MUST verify and record:

- exact upstream repository and owner;
- pinned commit and release, if any;
- exact license files and notices;
- dependency licenses;
- Rust workspace layout;
- persistence technology and migrations;
- web UI technology;
- authentication model;
- webhook model;
- provider support and capability differences;
- agent execution and sandbox model;
- review, auto-fix, and merge behavior;
- extension seams versus required fork patches;
- current build, test, security, and deployment instructions.

Until that inventory is complete, statements about upstream internals are hypotheses rather than implementation facts.

## 5. License and Distribution Requirements

The repository MUST include:

- the exact upstream license;
- retained copyright and attribution notices;
- a list of upstream modifications;
- a source-offer and deployment review checklist appropriate to the license;
- a legal-review gate before offering the system as a network service to third parties;
- an automated check that required notices remain in release artifacts.

No document may describe the resulting distribution as permissively licensed. License interpretation must be reviewed by qualified counsel when external service delivery is contemplated.

## 6. Extension-First Fork Strategy

Use this order of preference:

1. upstream configuration;
2. upstream plugin or trait extension points;
3. new IDWP crates with narrow integration boundaries;
4. small, isolated upstream patches;
5. invasive upstream modification only when no safer option exists.

Maintain:

- `UPSTREAM.md` with repository, commit, and rebase instructions;
- `PATCHES.md` with every behavioral patch and rationale;
- an automated upstream compatibility suite;
- a scheduled upstream review cadence;
- a clean separation between upstream code and IDWP-owned modules.

## 7. Provider Neutrality Is a Release Gate

Core types MUST use neutral terms:

- `ChangeRequest`, not `GitHubPullRequest`;
- `ReviewDiscussion`, not `GitHubReviewThread`;
- `CommitGate`, not `GitHubCheckRun`;
- `ProviderIdentity`, not `GitHubApp`;
- `RepositoryProvider`, not `GitHubClient`.

Provider-specific identifiers and payloads belong only in adapter modules or bounded extension data.

A provider capability model MUST represent differences such as:

- pull or merge requests;
- inline comments;
- resolvable conversations;
- required checks;
- branch rules;
- merge queues;
- service identities;
- webhooks;
- local-only repositories with no forge.

When a provider cannot enforce a required control, production integration MUST fail closed unless a documented equivalent control exists.

## 8. Alternatives Rejected

### New LAMP implementation

Rejected because it recreates repository automation, agent execution, review loops, dashboard infrastructure, webhooks, and merge handling already available in the chosen upstream.

### GitHub Agentic Workflows as the primary runtime

Rejected as the primary foundation because it couples execution and governance too closely to GitHub Actions and GitHub-specific operations. Components or ideas may still be reused where license and architecture permit.

### Generic workflow engine without repository automation

Rejected as the primary foundation because too much repository, review, and merge behavior would remain custom.

## 9. Exit Criteria

The adoption may be reversed only if Epic 1 or later evidence shows that wshm:

- cannot be extended without unacceptable security weakening;
- cannot support provider-neutral abstractions without an unmaintainable fork;
- cannot expose or integrate the required MCP surface;
- cannot isolate implementer and reviewer identities;
- cannot capture reliable request-level telemetry;
- has licensing or operational obligations the owner no longer accepts.

Reversal requires a written architecture decision and migration plan.
