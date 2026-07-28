# Third-Party Notices

This file identifies the authoritative dependency inventories and required
license handling for the internal IDWP build. It does not replace the license
text shipped by an individual dependency.

## Rust dependencies

`Cargo.lock` is the authoritative resolved Rust inventory. The Epic 3 quality
gate uses `cargo metadata --locked` to require every non-workspace Rust package
to declare a license expression or license file and produces a CycloneDX 1.5
SBOM from that exact graph.

## Frontend dependencies

`web/bun.lock` and `web/package-lock.json` are the authoritative frontend
inventories. The quality gate requires each resolved registry package recorded
in `package-lock.json` to declare a license and includes it in the generated
CycloneDX inventory.

## Upstream application

wshm and the IDWP extension are governed by the unmodified root `LICENSE`.
`LICENSE_COMPLIANCE.md` explains why its custom SSPL-derived text must not be
described as unmodified SPDX `SSPL-1.0` or OSI-approved open source.

Before external distribution, generate and retain the SBOM, collect the actual
license texts required by its components, package `LICENSE`, `NOTICE`,
`THIRD_PARTY_NOTICES.md`, `LICENSE_COMPLIANCE.md`, `UPSTREAM.md`, and
`PATCHES.md`, and complete the required legal review.
