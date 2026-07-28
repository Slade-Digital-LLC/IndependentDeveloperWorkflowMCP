# Upstream and Linux Installation Guidelines

## Authority and scope

These rules apply to upstream synchronization, dependencies, Linux setup, VirtualBox validation, packaging, and deployment. The product requirements in `docs/idwp-spec` remain authoritative.

## Upstream baseline

- Keep `origin` pointed at `Slade-Digital-LLC/IndependentDeveloperWorkflowMCP` and `upstream` pointed at `wshm-dev/wshm`.
- Pin every accepted upstream baseline by full commit SHA in `UPSTREAM.md`.
- Never force-push or rewrite shared fork history to synchronize upstream.
- Inventory and document upstream changes before accepting them.
- Preserve upstream copyright and license files verbatim.
- Record every IDWP modification to upstream-owned source in `PATCHES.md`, including purpose, files, tests, and rebase risk.
- Prefer IDWP-owned scripts, documentation, modules, and extension seams over invasive upstream edits.

## Linux installer ownership

- `scripts/bootstrap-linux.sh` is the canonical source-development bootstrap for supported Debian/Ubuntu hosts.
- The script must remain shellcheck-friendly POSIX-oriented Bash, fail fast, and be safe to rerun.
- It must install or verify all system packages, Rust components, frontend tooling, and audit tooling required to clone, build, test, lint, and inspect the project.
- It must clone the public organization fork when the destination is absent and update only by fast-forward when the destination is an existing clean checkout.
- It must never discard local changes, embed credentials, use an unpinned project revision by default in CI/validation, or silently continue after a failed dependency installation.
- Support `--repo`, `--ref`, `--destination`, `--skip-build`, and `--skip-audit` so clean VM validation is reproducible.
- Keep dependency lists centralized in the script and document why a package is required when its purpose is not obvious.
- Use HTTPS for public source retrieval. Authentication for private alternatives must come from the caller's credential helper or environment, never the script.

## End-to-end maintenance

For every dependency, toolchain, build-command, or source-layout change:

1. update `scripts/bootstrap-linux.sh`;
2. update `docs/IDWP_LINUX_DEVELOPMENT.md`;
3. update the active implementation plan;
4. run the script in a clean supported Linux VM;
5. run the upstream web build, Rust format, build, tests, Clippy, and applicable license/advisory checks;
6. record the distribution, tool versions, exact commit, commands, and results.

Do not declare Linux installation verified from Windows, WSL, a container, or inspection alone when a VirtualBox run is required.

## VirtualBox test appliance

- The maintained test VM name is `IDWP-Debian12`.
- Use NAT with host TCP port `2222` forwarded to guest SSH port `22`.
- Allocate at least 2 CPUs, 4 GiB RAM, and 32 GiB dynamically allocated disk.
- Keep credentials out of source control. Test credentials are local-only and must be changed before reuse beyond the disposable test appliance.
- Take a `clean-os` snapshot after OS installation and a `epic-1-verified` snapshot only after successful bootstrap and validation.

## Licensing safety

- Do not describe the upstream license as OSI-approved open source.
- Treat upstream's `LICENSE` as a custom SSPL-derived source-available license unless qualified legal counsel determines otherwise.
- Do not remove or weaken the upstream license, service-source obligations, competitive-service restriction, copyright, or trademark terms.
- Before external hosted-service use, distribution, or commercial launch, require legal review and record the outcome in `LICENSE_COMPLIANCE.md`.
