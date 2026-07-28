# IDWP Code Path and Test Map

This map identifies ownership and the minimum safety net expected as each path
gains behavior. It does not claim future epic behavior already exists.

| Path | Ownership/boundary | Required verification |
|---|---|---|
| `idwp/crates/idwp-domain` | deterministic provider-neutral domain | exhaustive unit tests, state/policy properties, no external dependencies |
| `idwp/crates/idwp-application` | use cases and ports | unit tests with fakes; orchestration failure/idempotency tests |
| `idwp/crates/idwp-provider-contract` | neutral provider outcomes | contract serialization and adapter conformance |
| `idwp/crates/idwp-review-contract` | reviewer jobs/findings/attestations | schema, exact-head, signature, and lifecycle tests |
| `idwp/architecture-tests` | workspace dependency policy | positive graph plus forbidden/missing/unknown edge tests |
| `idwp/config` | sanitized examples | TOML parsing, placeholder and secret-pattern rejection |
| `scripts/validate-quality.sh` | local/CI quality contract | clean execution plus missing-tool/asset failure tests |
| `scripts/bootstrap-linux.sh` | Debian/Ubuntu setup | fresh exact-SHA VM run, idempotent rerun, dirty/wrong-origin rejection |
| `compat/epic2` | pinned OpenCode/MCP compatibility | dedicated unit, black-box, and bounded live compatibility gates |
| `src`, `web`, deployment/release paths | upstream wshm | unchanged upstream regression/smoke gates and patch-ledger review |

Every implementation plan must refine this map for its affected paths and
record exact commands/results rather than relying on this structural baseline.
