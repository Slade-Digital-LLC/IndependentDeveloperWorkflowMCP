# Epic 1 Upstream Baseline Implementation Plan

## Objective

Create the legally and technically verified wshm fork baseline, project guidance, reproducible Linux installer, and clean VirtualBox validation evidence. Do not implement IDWP feature code.

## Scope and constraints

- Preserve upstream source unchanged.
- Pin and inventory `wshm-dev/wshm`.
- Maintain the GitHub fork under Slade Digital LLC.
- Preserve the supplied specification under `docs/idwp-spec`.
- Stop before Epic 2.
- Runtime instructions prohibit sub-agent delegation unless explicitly requested. This overrides the shared OpenCode delegation requirement; independent architecture/license review is therefore recorded as blocked until an independent reviewer is authorized/available.

## Checklist

- [x] Identify upstream repository, branch, release, and commit.
- [x] Create organization fork and upstream remote.
- [x] Establish `master`, `develop`, and feature branches.
- [x] Preserve project specification and add repository guidance.
- [x] Inventory source, persistence, UI, providers, workflows, deployment, and tests.
- [x] Document license and architectural viability findings.
- [x] Add idempotent Linux bootstrap/copy script.
- [ ] Build/test pristine upstream.
- [ ] Create Debian 12 VirtualBox VM.
- [ ] Run clean-clone bootstrap and validation in VM.
- [ ] Run dependency/license/advisory evidence.
- [ ] Inspect release artifact notices.
- [ ] Complete independent architecture/license review.
- [ ] Update final evidence and commit the validated change.

## Testability and Verification

### Testability Assessment

Epic 1 adds shell automation and documentation, not product business behavior. The installer exposes repository, ref, destination, build, and audit choices as arguments; refuses dirty/non-Git destinations; and keeps network/tool installation explicit. Its external dependencies are apt repositories, rustup, Bun, GitHub, Cargo registries, and VirtualBox networking.

### Planned Test Coverage

- Shell parse check with `bash -n`.
- Help/invalid-option checks.
- Clean Debian 12 end-to-end install into a new destination.
- Rerun against an existing clean checkout to prove idempotent fast-forward behavior.
- Upstream web check/build and Rust fmt/build/test/Clippy.
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
- [ ] Run focused tests for the changed behavior.
- [ ] Run the broader relevant test suite.
- [ ] Run coverage tooling when available and review uncovered meaningful behavior.
- [ ] Confirm no flaky, order-dependent, or environment-dependent tests were introduced.
- [ ] Report exactly which tests passed, failed, were blocked, or were not run.

### Tests Added, Changed, or Relied Upon

Added:
- Linux bootstrap parse, argument, clean-clone, and rerun checks.

Relied upon unchanged:
- Upstream Rust tests protect its baseline behavior.
- Upstream Svelte check/build protects frontend compilation.

### Validation Results

| Command | Scope | Result | Notes |
|---|---|---|---|
| `bash -n scripts/bootstrap-linux.sh` | shell | Not run | Pending VM |
| `bun run check && bun run build` | frontend | Not run | Pending VM |
| `cargo fmt -- --check` | formatting | Not run | Pending VM |
| `cargo build --locked` | build | Not run | Pending VM |
| `cargo test --locked` | unit/integration | Not run | Pending VM |
| `cargo clippy --locked -- -D warnings` | lint | Not run | Pending VM |
| `cargo audit ...` | advisory | Not run | Pending VM |

### Coverage and Remaining Risk

The installer has no unit-test framework; clean-machine execution is the meaningful coverage. License conclusions require qualified counsel. Pro-only source and live provider parity remain outside Epic 1.

### Final Verification Status

- Focused tests: Not run
- Broader regression suite: Not run
- Integration tests: Not run
- Coverage: Not run; shell automation is validated end to end
- Live verification: GitHub upstream/fork metadata passed; VM pending
- Remaining unverified areas: Linux bootstrap/build, advisory scan, release notices, independent review

