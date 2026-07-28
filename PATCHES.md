# IDWP Patch Ledger

No upstream-owned Rust, frontend, deployment, or release code is modified in Epic 1.

Epic 1 adds only IDWP-owned governance, specifications, due-diligence records, and Linux bootstrap material. Future entries must identify the upstream baseline, files, purpose, extension point considered, tests, security/license impact, and expected rebase conflict risk.

## Epic 2 compatibility spike

- Baseline: the pinned upstream commit in `UPSTREAM.md`.
- Purpose: prove pinned OpenCode, Rust Streamable HTTP MCP, isolated reviewer
  launch, and telemetry interfaces before production integration.
- Files: `compat/epic2/**`, `scripts/bootstrap-linux.sh`, and Epic 2
  documentation.
- Extension point: IDWP-owned standalone compatibility crate; no upstream Rust
  or frontend source is changed.
- Tests: crate fmt/build/test/Clippy, black-box MCP/OpenCode discovery, clean
  Debian VirtualBox validation, and unchanged upstream regression gates.
- Security/license: test bearer credentials are runtime-only; `rmcp` is MIT;
  upstream license material remains unchanged.
- Rebase risk: low; bootstrap commands may need adjustment if upstream layout
  or pinned external interfaces change.

## Epic 3 extension workspace and quality gates

- Baseline: the pinned upstream commit in `UPSTREAM.md`.
- Purpose: create IDWP-owned crate boundaries and enforce architecture,
  warnings, tests, advisory, dependency-license, notice, sanitized-config, and
  SBOM quality gates without changing workflow behavior.
- Upstream-owned integration files: root `Cargo.toml`/`Cargo.lock`,
  `.github/workflows/ci.yml`, and `scripts/bootstrap-linux.sh`.
- IDWP-owned files: `idwp/**`, `scripts/validate-quality.sh`,
  `scripts/check-epic3-assets.py`, project guidelines, contributor/docs
  templates, notices, and the Epic 3 plan.
- Extension point: the upstream root package remains a workspace member and has
  no dependency on any IDWP crate; no `src/**`, frontend, deployment, or
  release-runtime source is modified.
- Tests: Cargo metadata, workspace format/build/test/Clippy, positive and
  negative dependency-boundary tests, asset/config/license/SBOM validation,
  Epic 2 compatibility gates, unchanged upstream regression/smoke checks, and
  exact-commit Debian VirtualBox bootstrap.
- Security/license: upstream `LICENSE` remains unchanged; internal dependency
  metadata is inventoried without describing the custom upstream license as
  OSI-approved.
- Rebase risk: moderate for the root manifest and CI/bootstrap integration;
  low for IDWP-owned paths.
