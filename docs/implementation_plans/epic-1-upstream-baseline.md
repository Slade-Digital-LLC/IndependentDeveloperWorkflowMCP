# Epic 1 Upstream Baseline Implementation Plan

## Objective

Create the legally and technically verified wshm fork baseline, project guidance, reproducible Linux installer, and clean VirtualBox validation evidence. Do not implement IDWP feature code.

## Scope and constraints

- Preserve upstream source unchanged.
- Pin and inventory `wshm-dev/wshm`.
- Maintain the GitHub fork under Slade Digital LLC.
- Preserve the supplied specification under `docs/idwp-spec`.
- Stop before Epic 2.
- Architecture decision: proceed for organization-internal use; independently implement required Pro-only equivalents when needed.
- Independent review was explicitly authorized for promotion. The requested `gpt-5.6-terra` routing was not honored by the child runtime; its handoff reported GPT-5 Codex as the actual model.

## Checklist

- [x] Identify upstream repository, branch, release, and commit.
- [x] Create organization fork and upstream remote.
- [x] Establish `master`, `develop`, and feature branches.
- [x] Preserve project specification and add repository guidance.
- [x] Inventory source, persistence, UI, providers, workflows, deployment, and tests.
- [x] Document license and architectural viability findings.
- [x] Add idempotent Linux bootstrap/copy script.
- [x] Build/test pristine upstream.
- [x] Create Debian 12 VirtualBox VM.
- [x] Run clean-clone bootstrap and validation in VM.
- [x] Run dependency/license/advisory evidence.
- [x] Inspect release artifact notices.
- [ ] Complete independent architecture/license review and finding recheck.
- [x] Update final evidence and commit the validated change.

## Testability and Verification

### Testability Assessment

Epic 1 adds shell automation and documentation, not product business behavior. The installer exposes repository, ref, destination, build, and audit choices as arguments; refuses dirty/non-Git destinations; and keeps network/tool installation explicit. Its external dependencies are apt repositories, rustup, Bun, GitHub, Cargo registries, and VirtualBox networking.

### Planned Test Coverage

- Shell parse check with `bash -n`.
- Help/invalid-option checks.
- Clean Debian 12 end-to-end install into a new destination.
- Rerun against an existing clean checkout to prove idempotent fast-forward behavior.
- Upstream web build and Rust fmt/build/test/Clippy.
- Diagnostic `bun run check`, recorded separately because it is not an upstream CI gate.
- Cargo advisory scan and dependency/license inventory.
- Clean clone SHA verification.

No live provider writes are required or authorized.

### Database, Resource, and Parallelism Strategy

Rust tests use temporary/in-memory SQLite according to upstream fixtures. The VirtualBox VM is isolated and runs validation sequentially because package managers, Cargo cache, checkout destination, and VM lifecycle are shared resources.

### Live Verification Strategy

Read-only HTTPS access to GitHub, rustup, Bun, Debian mirrors, and Cargo registries is required. No production databases or provider mutations occur during tests. The only GitHub mutation is the explicitly requested organization fork/branch setup.

### Testability and Verification Checklist

- [x] Identify all new or changed behaviors.
- [x] Identify business logic, side effects, and external dependencies.
- [x] Confirm business logic is separated from UI, framework, database, and network code (not applicable; no feature logic).
- [x] Confirm time, randomness, configuration, concurrency, and external services are controllable in tests.
- [x] Define the required unit tests (shell-level argument/error checks).
- [x] Define the required integration tests (clean VM bootstrap).
- [x] Define whether live API or live external-database tests are required (not required).
- [x] Define database isolation, cleanup, ordering, and parallel-execution rules.
- [x] Add or update tests before or alongside the implementation.
- [x] Cover normal, boundary, invalid, duplicate, and failure cases in proportion to setup-script risk.
- [x] Add a regression test for every fixed defect when practical (no product defect).
- [x] Run focused tests for the changed behavior.
- [x] Run the broader relevant test suite.
- [x] Run coverage tooling when available and review uncovered meaningful behavior (not applicable; no product behavior changed and no upstream coverage gate).
- [x] Confirm no flaky, order-dependent, or environment-dependent tests were introduced.
- [x] Report exactly which tests passed, failed, were blocked, or were not run.

### Tests Added, Changed, or Relied Upon

Manual integration scenarios:
- Linux bootstrap parse, help, invalid-option, clean-clone, and rerun checks.
- No standalone automated test harness was added; the disposable Debian VM is the meaningful installer boundary test.

Relied upon unchanged:
- Upstream Rust tests protect its baseline behavior.
- Upstream Svelte check/build protects frontend compilation.

### Validation Results

| Command | Scope | Result | Notes |
|---|---|---|---|
| `bash -n scripts/bootstrap-linux.sh` | shell | Passed | Host Bash and independent reviewer |
| `bun run check` | frontend diagnostic | Failed | 12 errors and 5 warnings in five unmodified upstream Svelte files; not an upstream CI gate |
| `bun run build` | frontend baseline | Passed with warnings | Production assets built; upstream accessibility/reactivity warnings remain |
| `cargo fmt -- --check` | formatting | Passed | No formatting drift |
| `cargo build --locked` | build | Passed | Debug build completed |
| `cargo test --locked` | unit/integration | Passed | 81 passed, 0 failed; one doctest ignored |
| `cargo clippy --locked -- -D warnings` | lint | Passed | No Clippy warnings |
| `cargo audit --ignore ...` | advisory | Passed with warnings | Exit 0; six upstream ignores and eight allowed warning advisories |
| `bootstrap-linux.sh --skip-build` rerun | idempotence | Passed after fix | Initial sentinel deletion defect fixed; fast-forward rerun clean at `7306e53` |
| `bootstrap-linux.sh --ref 005034b... --skip-build` | pinned fresh clone | Passed | Exact detached HEAD and clean status in Debian VM |
| Wrong-origin existing checkout scenario | source safety | Passed | Exit 1 with explicit mismatch; existing remote unchanged |
| Correct-origin feature branch rerun | branch update | Passed | Updated to `005034b`; tracking branch and clean status verified |
| Existing shallow branch fast-forward | history safety | Passed | Unshallowed and fast-forwarded to `6d147b0` |
| Existing clean branch ahead of remote | history safety | Passed | Exit 1; local HEAD and clean state preserved |
| Existing clean branch diverged from remote | history safety | Passed | Exit 1; local HEAD and clean state preserved |
| Release checksum and archive inventory | distribution | Passed with finding | SHA-256 matched; archive contains only binary and lacks license/notices |

### Coverage and Remaining Risk

The installer has no unit-test framework; clean-machine execution is the meaningful coverage. The final checkout was clean after a full build. Pro-only source and live provider parity remain outside Epic 1. External access/distribution is not part of the approved internal deployment; changing that scope reopens license review.

### Final Verification Status

- Focused tests: Passed — shell parse/help, clean bootstrap, and idempotent rerun
- Broader regression suite: Passed — 81 Rust tests, no failures
- Integration tests: Passed — clean Debian VirtualBox install/copy/build
- Coverage: Not run — no product behavior changed; clean-machine execution covers installer behavior
- Live verification: Passed — GitHub metadata/fork and public dependency/release endpoints; no provider writes
- Remaining unverified areas: independent architecture/license review; Pro/live provider behavior outside Epic 1
