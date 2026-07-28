# Epic 2 OpenCode, MCP, and Telemetry Compatibility Spike

## Objective

Prove and pin the exact interfaces connecting OpenCode, authenticated Rust
Streamable HTTP MCP, isolated reviewer execution, wshm telemetry correlation,
and request-level usage capture without implementing production workflow logic.

## Current State

- Branch: `feature/epic-2-opencode-mcp-telemetry`
- Repository: `C:\Users\jcove\source\repos\IndependentDeveloperWorkflowMCP`
- Workspace: `C:\CodexWorkspace\IndependentDeveloperWorkflowMCP`
- Upstream baseline: documented in `UPSTREAM.md`
- OpenCode latest observed release and validation pin: `v1.18.7`

## Applicability Summary

- [x] [Model: openai/gpt-5] `AGENTS.md` — authoritative routing and Epic 2
  boundary.
- [x] [Model: openai/gpt-5] `CHECKIN_GUIDELINES.md` — feature PR,
  independent review, promotion, sync-back, and native thread resolution.
- [x] [Model: openai/gpt-5] `IMPLEMENTATION_PLAN_GUIDELINES.md` — this plan
  records scope, routing, validation, and check-in evidence.
- [x] [Model: openai/gpt-5] `MODEL_DELEGATION_GUIDELINES.md` — applies to
  bounded discovery, test review, and independent PR review.
- [x] [Model: openai/gpt-5] `AI_AGENT_GUIDELINES.md` — applies to OpenCode
  launcher profiles, machine-readable output, tool restrictions, and telemetry.
- [x] [Model: openai/gpt-5] `USER_DOCUMENTATION_GUIDELINES.md` — applies to
  developer-facing compatibility and Linux setup documentation.
- [x] [Model: openai/gpt-5] `SOLUTION_STRUCTURE_GUIDELINES.md` — considered;
  the compatibility crate is deliberately standalone and not an application
  solution/workspace member because production IDWP crates begin in Epic 3.
- [x] [Model: openai/gpt-5] `Project Specific Guidelines/AI_CODING_AGENT_TESTING_GUIDELINES.md`
  — applies to external boundaries, deterministic fixtures, negative paths,
  and live compatibility verification.
- [x] [Model: openai/gpt-5] `Project Specific Guidelines/UPSTREAM_AND_LINUX_INSTALL_GUIDELINES.md`
  — applies to dependencies, bootstrap changes, VirtualBox validation, upstream
  patch accounting, and GitHub review workflow.
- [x] [Model: openai/gpt-5] `CSHARP_GUIDELINES.md`,
  `DESKTOP_WPF_GUIDELINES.md`, and `DOTNET_PROJECT_METADATA_GUIDELINES.md` —
  not applicable; no .NET code or metadata.
- [x] [Model: openai/gpt-5] `JAVASCRIPT_GUIDELINES.md`, `CSS_GUIDELINES.md`,
  `HTML_FRONTEND_GUIDELINES.md`, and `WEB_DEVELOPMENT_GUIDELINES.md` — not
  applicable; no browser application behavior or presentation changes.
- [x] [Model: openai/gpt-5] `DATABASE_GUIDELINES.md` — not applicable; the
  compatibility server uses restart-stable test fixtures and no database.
- [x] [Model: openai/gpt-5] `SAVE_FILE_GUIDELINES.md` — not applicable; JSON
  examples are compatibility fixtures, not user-authored durable save formats.
- [x] [Model: openai/gpt-5] `WINDOWS_INSTALLER_GUIDELINES.md` and
  `JAVA_DESKTOP_GUIDELINES.md` — not applicable.

## Epic Boundary and Design

- Add a standalone `compat/epic2` Rust crate and black-box harness.
- Do not add production IDWP crates, workflow state, persistence, provider
  administration, or user-facing UI.
- Use authenticated Streamable HTTP and an explicit state probe whose
  authoritative fixture survives server restart.
- Treat OpenCode JSON output and server/event APIs as observed compatibility
  inputs, not a stable accounting source unless proven.
- Distinguish implementation and reviewer sessions with separate configuration,
  directories, agents, and captured session IDs; reviewer permissions are
  read-only.
- Record unsupported telemetry as unavailable or calculated, never zero.

## Affected Paths and Validation

| Path | Purpose | Validation |
|---|---|---|
| `compat/epic2/**` | MCP prototype, launcher, fixtures, tests | crate fmt/clippy/test; black-box protocol tests |
| `scripts/bootstrap-linux.sh` | pinned OpenCode install and compatibility test command | shell parse; clean Debian 12 VM |
| `docs/IDWP_LINUX_DEVELOPMENT.md` | setup and validation instructions | command review; clean VM |
| `docs/EPIC_2_COMPATIBILITY.md` | version matrix, contracts, telemetry, risks | independent technical review |
| `PATCHES.md` | identify IDWP-owned additions/no upstream source modification | review |
| `docs/implementation_plans/epic-2-opencode-mcp-telemetry.md` | execution evidence | maintained throughout |

## Work Plan

- [x] [Model: openai/gpt-5-codex] Inspect official OpenCode v1.18.7
  CLI, config, MCP, server/event, session, and telemetry interfaces.
- [x] [Model: openai/gpt-5-codex] Derive compatibility and failure-path
  tests from the four mandatory Epic 2 specifications.
- [x] [Model: openai/gpt-5] Pin the OpenCode version and Rust MCP SDK/transport
  decision.
- [x] [Model: openai/gpt-5] Implement the authenticated Streamable HTTP
  compatibility server and restart-stable state probe.
- [x] [Model: openai/gpt-5] Implement launcher contracts and telemetry
  normalization fixtures for implementation and reviewer sessions.
- [x] [Model: openai/gpt-5] Add automated protocol, auth, resource, error,
  reconnect, restart, timeout, delegation, retry, and drift tests.
- [x] [Model: openai/gpt-5] Update Linux bootstrap and developer documentation.
- [x] [Model: openai/gpt-5] Run focused compatibility validation.
- [x] [Model: openai/gpt-5] Run upstream regression validation.
- [x] [Model: openai/gpt-5] Run clean Debian 12 VirtualBox validation at the
  exact feature commit.
- [ ] [Model: independent reviewer] Complete technical review and resolve all
  native GitHub review conversations.
- [ ] [Model: openai/gpt-5] Merge feature PR to `develop`, promote to `master`,
  sync back, and finalize the local workspace.

## Test Strategy

- Unit tests for authentication, correlation, event normalization, unavailable
  fields, role separation, and restart-stable fixture behavior.
- In-process/black-box MCP protocol tests for initialize, tools, resources,
  protocol errors, unauthorized requests, session reuse, and restart.
- CLI contract tests for exact OpenCode version, MCP discovery, JSON events,
  timeout/cancellation, implementation/reviewer separation, and read-only
  reviewer permissions.
- Live OpenCode calls use a bounded inexpensive route and sanitized prompts;
  credentials remain in approved runtime stores.
- Full upstream Rust and frontend gates run because bootstrap/build behavior is
  changed.

## Delegation Records

Two read-only collaboration routes were requested as GPT-5.6 Terra/high:

1. `/root/epic2_opencode_interfaces` inspected OpenCode v1.18.7 official
   release/tag/source, launcher, MCP, permissions, events, session APIs, and
   telemetry. Its structured handoff reported GPT-5 Codex as the actual model.
2. `/root/epic2_test_matrix` derived the normative acceptance mapping,
   negative paths, telemetry quality classifications, and strict Epic 2
   boundary. Its structured handoff reported GPT-5 Codex as the actual model.

Ownership transition for each route: `delegated to gpt-5.6-terra -> incomplete
due runtime model mismatch -> reassigned to GPT-5 Codex`. Scope remained
read-only and bounded; the parent verified release metadata, source paths, CLI
help, Rust SDK examples, fixtures, and live behavior. No escalation remains.

## Validation Record

| Check | Result | Evidence |
|---|---|---|
| Rust fmt/build/test/Clippy | Passed | Debian 12; 5 unit tests; warnings denied |
| Authenticated MCP black box | Passed | auth, initialize, tools, resources, safe error |
| Restart/reconnect | Passed | new MCP session; external revision/value preserved |
| OpenCode discovery | Passed | 1.18.7 reported MCP server connected |
| Live implementation tool call | Passed | session `ses_0595b71d7ffeB2TidAyhB36eo3` |
| Live reviewer tool call | Passed | distinct session `ses_05959d3d0ffeP8VF9aFZONakNC` |
| Reviewer write denial | Passed | edit tool absent; requested file not created |
| Free-route cost provenance | Partial | numeric zero observed; currency/provenance unavailable |
| Clean-clone source and tool pin | Passed | exact commit `3c74d0968e52a663cbc50c6866d6bec9d7959593`; OpenCode 1.18.7 |
| Upstream frontend production build | Passed with known warnings | unchanged upstream Svelte warnings retained |
| Upstream Rust regression | Passed | fmt/build/Clippy; 81 tests passed, 0 failed; one doctest ignored |
| Focused compatibility gates | Passed | fmt/build/Clippy; 5 tests passed; black-box protocol suite passed |

## Deviations

- The VM-only isolated free-route call timed out; the successful bounded live
  calls used pinned OpenCode on the authenticated host against the Rust server
  in Debian over a temporary loopback VirtualBox forward. The forward was
  removed afterward.
- Requested Terra child routes ran as GPT-5 Codex; the actual model and
  ownership transitions are recorded.
- The canonical bootstrap was interrupted twice by the VirtualBox Guest
  Control transport after it had installed dependencies, pinned OpenCode, and
  reached the frontend build. Its fail-closed dirty-checkout guard correctly
  rejected a rerun until the interrupted generated-output sentinel was
  restored. After restarting the VM, the exact checkout remained intact and
  every canonical build/test command was run individually to completion.
- A deliberately mistyped expanded commit SHA failed before checkout and did
  not produce false validation evidence.

## Lessons Learned

- CLI NDJSON alone cannot establish actual provider/model; correlate the
  authenticated server event/session API.
- OpenCode's numeric zero cost is not authoritative without currency and
  provenance.
- Restart-safe authority must be external to the MCP transport session.
- Long-running Guest Control sessions are not reliable evidence boundaries;
  preserve command-level results and verify the exact checkout remains clean.

## Check-In Tracking

- Feature commit: `3c74d0968e52a663cbc50c6866d6bec9d7959593`
- Feature PR to `develop`: pending
- Independent review: pending
- Release PR to `master`: pending
- Sync-back PR to `develop`: pending
