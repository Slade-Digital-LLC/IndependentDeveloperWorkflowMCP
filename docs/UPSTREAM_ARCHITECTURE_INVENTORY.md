# Upstream Architecture and Capability Inventory

Baseline: `wshm-dev/wshm@96a8599996be04acdffbc157a5e4e76a31b6c84f` (`0.31.7`).

## Physical architecture

| Area | Verified implementation |
|---|---|
| Runtime | Single Rust 2021 package producing the `wshm` CLI/binary |
| Async/API | Tokio, Axum, Tower, rustls |
| Persistence | OSS SQLite through `rusqlite` with bundled SQLite; schema/migrations are Rust SQL in `src/db/schema.rs` plus separate auth/secrets databases |
| PostgreSQL | Advertised/documented in places, but implementation and SQLite migration are explicitly Pro-only and absent from OSS |
| Frontend | Svelte 5, SvelteKit static adapter, Vite 6, Tailwind 4; compiled assets embedded by Rust |
| Queue | Ranked merge-queue calculation is present; no durable external message broker |
| Webhooks | Axum webhook receiver with payload limits, signature handling, delivery deduplication, and polling reconciliation primitives |
| Deployment | Local binary, Docker Compose, systemd generation, Dockerfile, Kubernetes, Helm, and Kustomize |
| Tests | 81 Rust unit/async test attributes at inspection; CI runs Linux/Windows build, tests, fmt, Clippy, security scans, and Linux smoke |

## Provider capability matrix before IDWP changes

| Capability | GitHub | GitLab | Gitea/Forgejo | Azure DevOps |
|---|---|---|---|---|
| Provider module | Present | Present | Present | Present |
| Read/list issues or equivalent | Mature GitHub path | Adapter path | Adapter path | Work-item mismatch noted |
| Pull/change-request reads | Present | Present | Present | Present |
| Comments/labels | Present | Present | Present | Partial semantic mapping |
| Webhook handling | GitHub-centered | Generic delivery fallback only | Generic delivery fallback only | Not proven end to end |
| Merge execution | Not complete; merge queue contains TODO | Not proven | Not proven | Not proven |
| Branch protection/rulesets | Not found as governance administration | Not found | Not found | Not found |
| Provider-visible independent review loop | Pro hooks/docs, not an OSS enforceable gate | Not proven | Not proven | Not proven |

“Present” means code exists, not that IDWP's future provider conformance contract is satisfied. No provider is accepted as enforced in Epic 1.

## Security capability matrix before IDWP changes

| Control | Baseline |
|---|---|
| Transport | rustls-supported HTTP server/client paths |
| Local secrets | AES-256-GCM store with master key |
| External vaults | Optional HashiCorp, AWS, and GCP compile features; Azure is documented but no corresponding Cargo feature/module is present |
| Web authentication | Local accounts/session support; SSO/RBAC documentation is largely Pro-oriented |
| Webhook integrity | Signature/delivery processing exists; provider-neutral enforcement not proven |
| Least privilege separation | No separate IDWP implementation/reviewer/workflow identities |
| Audit | Secrets audit and event/usage tables exist, but not the immutable IDWP governance audit model |
| Gate anti-spoofing | Not present |
| Branch policy administration | Not present |

## Workflow and agent findings

- Triage, pull-request analysis, health checks, queue scoring, backup/restore, context export, revert, daemon scheduling, web API, and dashboard foundations exist.
- AI access is implemented directly through provider clients and prompts; no OpenCode/MCP integration was found.
- Review/fix/conflict/improve/changelog/report capabilities are described as Pro features and reached through Pro hooks or unavailable implementations.
- The OSS merge queue calculates/ranks candidates, but an inspected code path still contains `TODO: actual merge via GitHub API`.
- The code is GitHub-centered in configuration and mature synchronization even though a provider trait and three additional adapters exist.

## Disproved or corrected specification assumptions

1. Upstream is not a multi-crate Rust workspace; it is one Cargo package plus a separate frontend directory.
2. The license is not unmodified standard SSPL v1; it is custom SSPL-derived text with an added competitive-service restriction.
3. PostgreSQL and SQLite-to-PostgreSQL migration are not OSS extension seams; they are explicitly Pro-only.
4. Review/fix loops and portions of the dashboard/daemon feature set cannot be assumed reusable in the OSS fork without licensing/source availability analysis.
5. Azure Key Vault is documented, but the inspected OSS feature/module list contains HashiCorp, AWS, and GCP vault implementations, not Azure.
6. Existing merge-queue behavior does not prove merge execution.
7. Existing provider modules do not prove equivalent provider semantics or governance enforcement.

## Architecture decision

Continue only as a conditional evaluation baseline. The Rust/SQLite/Axum/Svelte code provides useful primitives, but the custom license and Pro-only boundaries materially weaken the original adoption assumptions. Before Epic 3 commits to extension architecture, obtain legal approval and complete Epic 2 interface probes. If competitive hosted use or required Pro-only source cannot be authorized, exit wshm and select a permissively licensed foundation.

