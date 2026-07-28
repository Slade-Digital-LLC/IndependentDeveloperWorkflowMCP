# Rust Engineering Guidelines

## Scope

Apply to every IDWP Rust crate, service, test, and workspace manifest. The
normative architecture remains `docs/idwp-spec/002_ARCHITECTURE.md`.

## Dependency Direction

- Dependencies point inward: adapters/transports/UI -> application -> domain.
- `idwp-domain` has no provider, wshm, persistence, MCP, process, network, or
  web-framework dependency.
- Upstream `wshm-core` does not depend on IDWP crates until an epic explicitly
  introduces and tests an integration seam.
- Every new IDWP crate and internal edge must be classified in the executable
  architecture allowlist; unknown edges fail closed.

## Design

- Prefer typed inputs, explicit results, pure deterministic logic, small
  cohesive modules, and constructor/trait injection at external boundaries.
- Forbid unsafe Rust unless narrowly justified, independently reviewed, and
  covered by safety tests.
- Do not create placeholder domain types before their authoritative epic.

## Required Gates

- `cargo fmt --all -- --check`
- workspace locked build and tests
- workspace all-target Clippy with `-D warnings`
- architecture tests, license/notice checks, advisory scan, and SBOM generation
- exact-head Debian bootstrap when workspace/tooling changes
