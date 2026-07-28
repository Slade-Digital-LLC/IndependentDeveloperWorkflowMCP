# Independent Development Workflow Platform - Guideline Translation for Rust and wshm

**Status:** Normative implementation guidance  
**Version:** 2.0  
**Date:** 2026-07-27

## 1. Purpose

The original guideline set was written largely for C#, JavaScript, CSS, databases, WISA/LAMP deployment, and Azure DevOps/GitHub workflows. IDWP must preserve those rules in spirit while using Rust and the wshm upstream.

Literal stack-specific instructions that no longer apply are translated into equivalent outcomes. This document does not weaken security, review, validation, documentation, or testability requirements.

## 2. Instruction Precedence

1. Direct user instructions.
2. Project-specific IDWP guidelines.
3. Applicable reusable guidelines.
4. Root `AGENTS.md`.
5. Upstream wshm conventions where they do not conflict with higher-priority requirements.

Security prohibitions and required workflow gates cannot be overridden by convenience.

## 3. Check-In and Independent Review

Preserve:

- feature branches from development branch;
- release branches from development branch;
- hotfix branches from production branch;
- no direct protected-branch commits;
- change-request-only integration;
- complete production promotion path;
- sync-back to development;
- branch cleanup;
- independent review before required integrations;
- visible review conversation;
- reviewer recheck after fixes;
- no implementation self-closure;
- documented exceptions;
- final local checkout of current clean development branch.

Provider-specific thread/status names are mapped through neutral states and adapter behavior.

## 4. Implementation Plans

Every epic/file-changing endeavor retains a workspace implementation plan containing:

- objective and scope;
- branch and upstream revision;
- guideline applicability checklist;
- affected crates/services/providers/UI/data paths;
- code-path-to-test mapping;
- build/lint/test/security/license results;
- migrations and provider configuration;
- reviewer identity/runtime/findings/responses/rechecks;
- commits/change requests;
- deviations and lessons;
- cost/telemetry verification;
- upstream patches introduced;
- rollback and release evidence.

## 5. Rust Engineering Rules

Translate C# design principles to Rust:

- clear maintainable code over cleverness;
- small cohesive modules and functions;
- explicit dependency injection through traits/constructors;
- domain logic independent of transport, provider, framework, and persistence;
- avoid global mutable state;
- deterministic pure logic where possible;
- one primary responsibility per type/module;
- typed inputs and outputs;
- errors represented explicitly, not swallowed;
- avoid unsafe Rust unless narrowly justified, reviewed, and tested;
- no provider-specific types in domain crates;
- public APIs documented where non-obvious;
- comments explain why, constraints, and safety, not obvious mechanics.

Required baseline tools, adjusted to upstream:

- `cargo fmt --check`;
- `cargo clippy --all-targets --all-features -- -D warnings` or approved workspace equivalent;
- `cargo test --workspace --all-features`;
- dependency/advisory scan such as `cargo audit` or approved equivalent;
- license/SBOM scan;
- architecture/dependency-boundary tests;
- no unresolved warnings.

## 6. Testability and Coverage

Testable code and full meaningful unit coverage are required, not optional.

Requirements:

- state machine and policy are pure/deterministic where practical;
- provider APIs behind traits and fakes;
- time, randomness, IDs, filesystem, process launch, network, and model runtimes injectable;
- no live provider required for unit tests;
- disposable sandbox repositories for integration tests;
- reviewer OpenCode process wrapper testable with fake process runner;
- database tests isolated and deterministic;
- shared database fixtures reset between tests;
- parallel tests enabled only when isolation is proven;
- live provider tests used for final integration paths with safe test organizations/repositories;
- every affected code path maps to automated or approved live verification.

Coverage percentage alone does not prove completeness, but untested non-trivial behavior is non-compliant.

## 7. Database Guidelines

Preserve intent:

- centralized connection/pool creation;
- explicit repository/query layer;
- parameterized queries;
- versioned migrations;
- named constraints/indexes where supported;
- audit fields;
- provider-specific SQL isolated;
- explicit transactions;
- production write protection;
- read-only diagnostics allowed where authorized;
- no startup migration against production without explicit deployment authorization;
- no secrets in migrations or fixtures.

Use upstream database/migration framework rather than introducing a second stack without need.

## 8. Configuration and Secrets

Preserve environment separation and explicit configuration validation, adapted to upstream conventions.

- no plaintext durable secrets in repository or ordinary `.env` files;
- local development examples use placeholders;
- runtime secret store or mounted protected credentials;
- no secrets in command arguments/logs;
- separate reviewer/workflow/implementer identities;
- least privilege;
- rotate/test credentials;
- fail clearly when a secret is missing without asking user to paste it into chat.

## 9. Web UI and Accessibility

Extend upstream UI using its established frontend stack and design system.

Preserve:

- WCAG 2.2 AA;
- keyboard support;
- visible focus;
- semantic markup;
- labels and accessible errors;
- no color-only meaning;
- accessible dynamic updates;
- loading feedback and double-submit prevention;
- full useful error detail without secrets;
- consistent operational shell;
- local/static dependencies where policy requires;
- deterministic browser tests for browser-dependent behavior;
- report charts with equivalent accessible tables.

Do not rewrite the upstream UI framework solely to match old Bootstrap/CSS prescriptions. Preserve outcomes and document exceptions.

## 10. Documentation

Maintain user-centered documentation for:

- installation and upgrade;
- provider setup;
- workflow commands;
- review/fix behavior;
- operations and failures;
- reporting and cost interpretation;
- permissions/roles;
- security and incident recovery;
- upstream fork maintenance;
- adapter development.

Indexes point to detailed feature documents. Do not leave stale duplicate documentation.

## 11. Solution/Repository Structure

Use the upstream Rust workspace structure where possible.

Add IDWP-owned crates/modules in clearly named locations. Keep:

- upstream code distinguishable from extension code;
- domain/provider/UI/deployment/test boundaries clear;
- guidelines and docs discoverable;
- pipeline files represented in repository tooling;
- patches and upstream metadata explicit;
- no generated build artifacts committed unless upstream requires them.

## 12. AI Prompt and Agent Guidelines

Reviewer and implementation prompts are application behavior:

- versioned;
- testable;
- complete rather than partial patch prompts;
- typed/structured outputs;
- tool manifests explicit;
- provider/model-specific code isolated;
- redundancy and conflicts removed;
- live-tested against configured runtime when safe;
- modifications require independent review;
- actual runtime/model recorded.

Evaluation prompts preserve reasonable qualitative judgment and must not become brittle scoring formulas.

## 13. Upstream Change Rules

Any upstream patch must:

- have a clear IDWP requirement;
- be as narrow as possible;
- include tests;
- be listed in `PATCHES.md`;
- include upstream/rebase risk;
- avoid duplicating an upstream extension point;
- receive independent review;
- preserve license notices.

## 14. Epic Checklist Template

Each epic implementation plan includes:

```markdown
## Applicability Summary

- [ ] Applicable - root AGENTS.md: reviewed and applied
- [ ] Applicable - check-in/review guidelines: branch, PR/MR, reviewer, promotion
- [ ] Applicable - implementation-plan guidelines: workspace and evidence
- [ ] Conditional - Rust engineering: affected crates/modules
- [ ] Conditional - database: persistence/migrations/queries
- [ ] Conditional - provider adapter: provider APIs/policy/webhooks
- [ ] Conditional - MCP/AI agent: tools/prompts/model runtime
- [ ] Conditional - web/accessibility: UI/reporting changes
- [ ] Conditional - secrets/security: identities/credentials/trust boundary
- [ ] Conditional - user documentation: user-visible behavior
- [ ] Applicable - upstream/license: patch, dependency, notice, rebase impact
```

Check boxes are completed only after actual review and validation.
