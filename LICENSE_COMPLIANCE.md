# License Compliance Baseline

This is an engineering inventory, not legal advice.

## Upstream license finding

The pinned upstream includes a single root `LICENSE` headed “Server Side Public License (SSPL) v1,” with copyright attributed to wshm-dev / Patrick Szymkowiak. GitHub reports the license as `NOASSERTION`.

The text is not the standard SSPL v1 text. It includes additional or altered terms, notably:

- a broad service-source disclosure obligation;
- a prohibition on using the program to offer a competing commercial service without authorization;
- custom contribution, trademark, patent, termination, and commercial-licensing clauses.

Accordingly, IDWP treats the dependency as custom SSPL-derived, source-available software. It must not be represented as OSI-approved open source or as unmodified SPDX `SSPL-1.0` without legal confirmation.

## Required handling

- Preserve upstream `LICENSE` and copyright notices verbatim.
- Retain source provenance and the exact pinned commit.
- Distribute corresponding source, installation/build scripts, configuration, and dependent service source when the service clause applies.
- Do not use upstream trademarks beyond attribution.
- Obtain written legal review before external hosted-service use, commercial launch, redistribution, or reliance on the “non-competing” interpretation.
- Re-run license review whenever upstream license text or dependency lockfiles change.

## Dependency evidence

The Rust dependency source of truth is `Cargo.lock`; the frontend sources are `web/bun.lock` and `web/package-lock.json`. Epic 1 validation uses Cargo's advisory database and lockfile metadata plus the frontend lockfile. A generated third-party notice/SBOM must be added before distributing artifacts.

The upstream release publishes checksums and platform archives/packages, but no standalone notice bundle was found at the pinned revision. Release artifacts therefore require the root license and generated dependency notices to accompany any IDWP redistribution.

## Decision

Internal evaluation and fork maintenance may continue subject to these controls. External service or commercial deployment is blocked pending counsel review of the custom competitive-service restriction and complete corresponding-source scope.

