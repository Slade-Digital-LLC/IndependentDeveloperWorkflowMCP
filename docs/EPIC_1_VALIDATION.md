# Epic 1 Validation Evidence

Validation date: 2026-07-27 (America/New_York)

## Environment

- Oracle VirtualBox 7.2.10
- VM: `IDWP-Debian12`
- Debian 12.15 guest (installed from Debian 12.13 netinst and updated)
- 4 vCPUs, 6 GiB RAM, 40 GiB dynamic VDI
- NAT with host `127.0.0.1:2222` forwarded to guest SSH 22
- Rust/Cargo 1.97.1
- Bun 1.3.14
- cargo-audit 0.22.2
- Validated IDWP revision: `7306e53f6557026201af5d93bc33a9c47837a6da`
- Pinned unchanged upstream source revision: `96a8599996be04acdffbc157a5e4e76a31b6c84f`

## Bootstrap results

The canonical `scripts/bootstrap-linux.sh` installed dependencies, cloned the organization fork into `/home/idwp/src/IndependentDeveloperWorkflowMCP`, and completed with exit code 0.

| Gate | Result | Evidence |
|---|---|---|
| Debian packages | Passed | Required packages installed; rerun reported all at newest installed versions |
| Rust toolchain/components | Passed | Stable 1.97.1; rustfmt and Clippy present |
| Bun install | Passed | Bun 1.3.14 |
| Clean source copy | Passed | Public organization branch cloned and exact revision verified |
| Frontend production build | Passed with warnings | Vite/Svelte build completed; upstream accessibility/reactivity warnings remain |
| Rust format | Passed | `cargo fmt -- --check` |
| Rust build | Passed | `cargo build --locked` |
| Rust tests | Passed | 81 passed, 0 failed; zero-test binary target passed; one doctest ignored |
| Rust Clippy | Passed | `cargo clippy --locked -- -D warnings` |
| Advisory scan | Passed with allowed warnings | `cargo audit` exited 0 using the six upstream CI ignores; eight warning-class advisories reported |
| Idempotent rerun | Passed | Existing clean checkout fast-forwarded and `--skip-build` completed |
| Post-build cleanliness | Passed | `git status --porcelain` empty after restoring upstream's tracked web-dist sentinel |

## Diagnostic failure retained

`bun run check` is not an upstream CI gate and fails on the unmodified pinned source with 12 errors and 5 warnings across five Svelte files. Epic 1 does not modify upstream product source to repair this. The production build used by upstream CI passes.

The first VM bootstrap attempt also failed closed because Debian rebooted with IPv6-only NetworkManager configuration and no working DNS. Re-activating the NAT connection with IPv4 DHCP produced `10.0.2.15/24` and restored the route. This was an appliance networking issue, not a bootstrap bypass.

## Dependency and release evidence

`cargo metadata --locked --format-version 1` reported 411 Rust packages with declared license expressions. The largest groups were:

- 209 `MIT OR Apache-2.0`;
- 70 `MIT`;
- 21 `MIT/Apache-2.0`;
- 18 `Apache-2.0 OR MIT`;
- 18 `Unicode-3.0`;
- 75 across other declared expressions.

No package reported a missing license expression. The root package declares `SSPL-1.0`; `LICENSE_COMPLIANCE.md` explains why the actual custom text still requires separate treatment.

The `v0.31.7` Linux x86_64 archive matched the published SHA-256 checksum. Archive inventory contained only:

```text
wshm
```

It did not contain the root license, notices, SBOM, or dependency license bundle. IDWP must add those materials before any future distribution.

## Unverified or blocked

- Live provider writes and Pro features were not run; they are outside Epic 1.
- Coverage tooling was not run because Epic 1 changes no Rust/product behavior and upstream defines no coverage gate.
- Independent architecture/license reviewer execution is blocked by the active runtime instruction that prohibits sub-agents unless explicitly requested. A strict self-review was performed, but it is not represented as independent review.

