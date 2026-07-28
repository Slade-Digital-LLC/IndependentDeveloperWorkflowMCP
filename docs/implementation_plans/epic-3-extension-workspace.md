# Epic 3 IDWP Extension Workspace and Quality Gates

## Objective and Boundary

Create compiling IDWP-owned Rust workspace crates, enforce dependency
direction, add reproducible local/CI quality gates, translate project
guidelines, and provide sanitized configuration and planning templates without
adding domain behavior, persistence tables, provider operations, reviewer
execution, UI behavior, or MCP tools.

- Branch: `feature/epic-3-extension-workspace`
- Base: `develop`
- Upstream baseline: `96a8599996be04acdffbc157a5e4e76a31b6c84f`
- Repository: `Slade-Digital-LLC/IndependentDeveloperWorkflowMCP`

## Applicability Summary

- [x] Applicable - root and shared `AGENTS.md`: authoritative routing and Epic
  boundary reviewed.
- [x] Applicable - check-in/review guidelines: feature PR, independent review,
  native conversation resolution, promotion, and sync-back required.
- [x] Applicable - implementation-plan guidelines: this file is the living
  scope, routing, test, review, and release record.
- [x] Applicable - model delegation guidelines: bounded architecture and test
  discovery plus independent PR review.
- [x] Applicable - Rust engineering and solution structure: workspace members,
  dependency direction, warnings, tests, and repository layout.
- [x] Applicable - AI coding-agent testing: mandatory testability mapping,
  architecture tests, failure paths, coverage, and exact reporting.
- [x] Applicable - user documentation: local validation, configuration, and
  contributor guidance.
- [x] Applicable - upstream/Linux/license: workspace/bootstrap/CI changes,
  notices, advisory/license/SBOM gates, clean VirtualBox validation, and patch
  accounting.
- [x] Conditional artifacts only - database, provider, reviewer, UI, and secret
  guidelines are added for future epics; no corresponding runtime behavior is
  implemented in Epic 3.
- [x] Not applicable - C#, WPF, Java desktop, save-file, Windows installer,
  HTML/CSS/JavaScript behavior, database migrations, provider API calls,
  production secrets, and MCP/AI prompt changes.

## Proposed Structure and Dependency Direction

IDWP-owned members will live below `idwp/` and preserve these allowed inward
edges:

```text
provider adapters / MCP / reporting -> application -> domain
policy / provider contract / review contract / cost / audit -> domain
reviewer service -> review contract
architecture tests -> workspace metadata only
```

`idwp-domain` must have no provider, wshm, web, persistence, MCP, process, or
framework dependency. Epic 3 crates remain skeletal and expose no workflow
business behavior.

## Work Plan

- [x] [Model: primary implementation agent] Add workspace membership and
  compiling skeletal IDWP crates/services.
- [x] [Model: delegated architecture analyst] Confirm minimal layout,
  dependency edges, and boundary enforcement.
- [x] [Model: delegated quality analyst] Map all gates and failure cases.
- [x] [Model: primary implementation agent] Add architecture tests and
  code-path/test mapping.
- [x] [Model: primary implementation agent] Add local validation and CI gates
  for fmt, Clippy, tests, advisory, licenses, notices, and SBOM generation.
- [x] [Model: primary implementation agent] Add project-specific Rust,
  database, provider, reviewer, UI, secret, and upstream guidance.
- [x] [Model: primary implementation agent] Add implementation-plan and
  code-path/test templates plus sanitized configuration examples.
- [x] [Model: primary implementation agent] Update Linux bootstrap,
  contributor documentation, and patch ledger.
- [x] [Model: primary implementation agent] Run focused and upstream
  regression gates.
- [x] [Model: primary implementation agent] Run the canonical bootstrap in a
  fresh Debian 12 VirtualBox checkout at the exact feature commit.
- [ ] [Model: independent reviewer] Review the feature PR and close every
  finding through the native GitHub conversation lifecycle.
- [ ] [Model: primary implementation agent] Merge to `develop`, promote to
  `master`, sync back, and leave local `develop` clean.

## Code-Path-to-Test Mapping

| Path or behavior | Planned verification |
|---|---|
| Root workspace and IDWP manifests | `cargo metadata`, locked workspace build/test |
| Skeletal public APIs | doc/unit tests proving crate identity and allowed dependency composition |
| Forbidden dependency edges | architecture integration tests with negative manifest fixtures |
| Formatting and warnings | workspace fmt and all-target/all-feature Clippy with `-D warnings` |
| Notices/license/SBOM | deterministic gate script, missing-file failures, license policy, generated CycloneDX validation |
| Sanitized examples | placeholder/secret-pattern validation and parse tests |
| CI workflow | YAML/action review plus local gate parity |
| Bootstrap | clean Debian 12 exact-commit run and idempotent rerun |
| Unchanged upstream | frontend build and upstream Rust regression suite |

## Testability and Verification

### Testability Assessment

Epic 3 adds structure and enforcement rather than business behavior. Workspace
topology is represented by Cargo manifests and tested from `cargo metadata`.
Architecture policy is isolated in deterministic code that accepts metadata or
manifest fixtures; it does not require a live provider, database, network, UI,
or fixed port. Quality checks are composed by a fail-fast local script used by
CI and the Linux bootstrap. Configuration validation consumes checked-in
sanitized examples only. Tool installation/download is separated from gate
logic and pinned where supported.

Time, randomness, concurrency, identity, provider services, and mutable
databases are not involved. Filesystem tests use temporary directories and
clean up automatically. The only live boundary is the maintained Debian
VirtualBox appliance used for final installer/build parity.

### Planned Test Coverage

- Architecture tests:
  - accept the checked-in allowed dependency graph;
  - reject domain-to-provider, domain-to-wshm, domain-to-web/persistence/MCP,
    and unknown IDWP dependency edges;
  - reject missing required workspace crates;
  - remain independent and parallel-safe through immutable fixtures.
- Quality-script tests:
  - pass with required license/notice/config/template assets;
  - fail for a missing notice or forbidden secret-like example;
  - validate generated SBOM structure.
- Workspace gates:
  - metadata, format, build, supported upstream default-feature tests and
    Clippy, plus all-feature tests and Clippy for every IDWP-owned crate;
  - advisory and license policy;
  - unchanged upstream frontend and Rust tests.
- Integration:
  - canonical clean Debian bootstrap at exact commit;
  - idempotent clean rerun;
  - no live provider, reviewer, database, or MCP call is required.

### Database, Resource, and Parallelism Strategy

No database or external mutable service is used. Unit and architecture fixture
tests may run in parallel. Filesystem fixtures are immutable or created in
unique temporary directories. Local/CI gate scripts run sequential commands
because they share Cargo build output, not because tests depend on order.
SBOM/notice outputs are written to temporary paths or deterministic ignored
build directories and cleaned by traps.

### Live Verification Strategy

The sole live environment is the maintained `IDWP-Debian12` VirtualBox
appliance. Host automation reads the `idwp` credential from Windows Credential
Manager target `IDWP/VirtualBox/IDWP-Debian12/idwp` without logging it. The
canonical bootstrap clones a fresh exact feature SHA, installs/verifies tools,
runs all gates, proves a clean checkout, and is rerun for idempotency. No
provider credentials or external writes are needed.

### Testability and Verification Checklist

- [x] Identify all new or changed behaviors.
- [x] Identify business logic, side effects, and external dependencies.
- [x] Confirm business logic is separated from UI, framework, database, and network code.
- [x] Confirm time, randomness, configuration, concurrency, and external services are controllable in tests.
- [x] Define the required unit tests.
- [x] Define the required integration tests.
- [x] Define whether live API or live external-database tests are required.
- [x] Define database isolation, cleanup, ordering, and parallel-execution rules.
- [x] Add or update tests before or alongside the implementation.
- [x] Cover normal, boundary, invalid, duplicate, and failure cases.
- [x] Add a regression test for every fixed defect when practical; no defect is in scope initially.
- [x] Run focused tests for the changed behavior.
- [x] Run the broader relevant test suite.
- [x] Run coverage tooling when available and review uncovered meaningful behavior; no coverage tool is installed, so branch/test mapping was reviewed.
- [x] Confirm no flaky, order-dependent, or environment-dependent tests were introduced.
- [x] Report exactly which tests passed, failed, were blocked, or were not run.

### Tests Added, Changed, or Relied Upon

Added:

- `idwp/architecture-tests/tests/workspace_boundaries.rs` - seven integration
  tests for the valid graph, reversed domain/provider edge, IDWP-to-upstream,
  upstream-to-IDWP, missing package, empty unknown IDWP package, and
  unclassified upstream-package failure.
- `scripts/tests/test_check_epic3_assets.py` - six deterministic unit tests for
  missing assets, valid/invalid/secret-like TOML, stable CycloneDX output,
  custom upstream licensing, and scoped npm PURL encoding.

Relied upon:

- unchanged upstream Rust suite - 81 tests protecting existing behavior;
- Epic 2 compatibility suite - 7 tests protecting the excluded standalone
  compatibility workspace after root workspace conversion.

### Validation Results

| Command | Scope | Result | Notes |
|---|---|---|---|
| `cargo fmt --all -- --check` | formatting | Passed | isolated Rust 1.97.1 host toolchain |
| `cargo build --workspace --all-targets --locked` | build | Passed | root plus five IDWP workspace packages |
| `cargo test --workspace --locked` | unit/integration/regression | Passed | 5 architecture + 81 upstream; one upstream doctest ignored |
| `cargo clippy --workspace --all-targets --locked -- -D warnings` | static analysis | Passed | warnings denied |
| `python -m unittest discover -s scripts/tests -p 'test_*.py'` | asset gate unit | Passed | 5 tests |
| `python scripts/check-epic3-assets.py --sbom <temp>` | license/notice/config/SBOM | Passed | aggregate Rust/frontend CycloneDX 1.5 |
| Epic 2 Cargo test/Clippy | compatibility regression | Passed | 7 tests; warnings denied |
| Bash syntax and `git diff --check` | scripts/diff | Passed | bootstrap/local/Epic 2 shell entry points |
| Upstream frontend production build | regression | Passed | Debian 12; known unchanged Svelte warnings retained |
| `bash scripts/validate-quality.sh` | canonical quality | Passed | Debian 12; advisory, 5+81 tests, asset/license/config/SBOM, Clippy |
| Epic 2 bootstrap gates and black box | compatibility integration | Passed | 7 tests; auth/protocol/restart/discovery; cleanup passed |
| Canonical Debian bootstrap | live integration | Passed | exact `fa10dfcfeee3a086b65ea2bfbfe092df2633f1a1`; clean checkout |
| Bootstrap idempotent rerun | installer | Passed | exact commit with `--skip-build`; no package/tool/source churn |
| Reviewer-fix Python regression suite | asset gate unit | Passed | 6 tests |
| Reviewer-fix host Cargo suite | Rust regression | Blocked | Cargo is not installed on the ordinary Windows host; exact-head Debian run required |
| Initial reviewer-fix all-workspace/all-feature gate | upstream optional features | Failed as designed | exposed 13 pre-existing async-constructor errors in optional upstream cloud/storage/vault code; narrowed to all IDWP features plus supported upstream defaults to preserve the Epic 3 boundary |

### Coverage and Remaining Risk

Structural policy and asset/config/SBOM validation have positive and negative
branch coverage. Skeletal crates intentionally contain no domain behavior.
The initial feature head passed Linux and Security CI while the remaining jobs
were still running when reviewer fixes began. The advisory database,
frontend build, canonical local script, SBOM/license/config checks, and Linux
setup passed in Debian. Cargo coverage tooling is not installed; meaningful new
branches are covered directly by ten focused tests.

### Final Verification Status

- Focused tests: Passed before review - 5 architecture and 5 asset-gate tests;
  reviewer-fix Python suite passed 6 tests and Rust rerun awaits Debian.
- Broader regression suite: Passed - 81 upstream and 7 Epic 2 tests.
- Integration tests: Passed - canonical quality and Epic 2 black box in Debian.
- Coverage: Not run - coverage tool unavailable; branch mapping reviewed.
- Live verification: Passed - exact-head Debian bootstrap and idempotent rerun.
- Remaining unverified areas: reviewer re-check, final-head GitHub CI, and
  final-head Debian rerun.

## Delegation Record

Two bounded read-only routes were requested without premium escalation:

1. `/root/epic3_architecture` reviewed workspace/dependency design and returned
   GPT-5 Codex as the actual runtime model. It recommended the adopted minimal
   four-crate product boundary plus architecture-test crate rather than
   speculative future crates.
2. `/root/epic3_quality_matrix` mapped all gates/failures. Its runtime exposed
   only "Codex child agent", not an exact identifier. It recommended a single
   local quality entry point, pinned audit tooling, negative architecture/asset
   tests, deterministic SBOM output, and exact-SHA Debian validation.

Complexity was routine-to-complex, risk moderate, and verifiability high; a
more expensive premium model was unnecessary. The parent verified recommendations
against manifests, executable tests, and repository policy. No escalation
remains.

## Review, Check-In, and Release Record

- Feature commits: `e625558`, `07f8c8a`, `918485c`, `fa10dfc`, `94034b2`
- Feature PR to `develop`: [#10](https://github.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP/pull/10)
- Independent reviewer: `/root/epic3_independent_review`, actual runtime
  reported as GPT-5 Codex; read-only full-diff review at `94034b2`.
- `Code Review 001` Active -> Pending: reject empty unclassified IDWP packages;
  accepted, package-level classification and regression test implemented.
- `Code Review 002` Active -> Pending: install pinned audit tooling before the
  `--skip-build` exit; accepted and reordered.
- `Code Review 003` Active -> Pending: align canonical all-feature tests and
  Clippy with the plan; accepted. Full upstream all-feature validation exposed
  pre-existing failures in optional cloud/storage/vault code outside Epic 3,
  so the enforced set is all IDWP-owned features plus supported upstream
  default features.
- `Code Review 004` Active -> Pending: do not emit the custom upstream license
  as SPDX `SSPL-1.0`; accepted, named custom-license output and regression
  assertion implemented.
- `Code Review 005` Active -> Pending: percent-encode scoped npm PURLs; accepted
  and covered by regression.
- `Code Review 006` Active -> Pending: reject unclassified upstream-to-IDWP
  edges; accepted and covered by regression.
- Native resolution verification: pending
- Release PR to `master`: pending
- Sync-back PR to `develop`: pending

## Deviations, Lessons, Rollback, and Upstream Impact

- Deviations: an initially mistyped full SHA failed closed before checkout.
  Two exact-head attempts then failed closed because Cargo's subcommand form
  reports `cargo-audit-audit 0.22.2`; version verification now calls the
  installed `cargo-audit` executable directly. The final canonical run passed.
- Lessons: version assertions must target the executable's canonical version
  surface and be tested under `set -o pipefail`; Cargo subcommand wrappers may
  alter program-name output.
- Rollback: revert IDWP-owned workspace/gate commits; no data migration or
  provider state exists.
- Upstream patches: none planned; root workspace/CI/bootstrap files are
  integration surfaces and will be recorded explicitly in `PATCHES.md`.
