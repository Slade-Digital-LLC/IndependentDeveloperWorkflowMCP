# Upstream and Linux Installation Guidelines

## Authority and scope

These rules apply to upstream synchronization, dependencies, Linux setup, VirtualBox validation, packaging, deployment, and GitHub pull-request review workflow. The product requirements in `docs/idwp-spec` remain authoritative.

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
- It must never discard local changes, embed credentials, use an unpinned project revision in reproducibility validation, or silently continue after a failed dependency installation.
- Its ordinary developer default must be the durable `master` branch; reproducibility and CI validation must pass an explicit full commit SHA.
- Existing destinations must prove their normalized `origin` matches `--repo` before any fetch, checkout, build, or execution.
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

## GitHub review comment formatting

- Build multiline PR review bodies with a real multiline here-string or an array joined with the platform newline.
- Never place PowerShell backtick newline sequences inside a single-quoted string; PowerShell preserves them literally and GitHub renders them as text.
- Before posting or updating a review comment, inspect the serialized body and confirm paragraph breaks are actual newline characters.
- After posting the first comment in a batch, read it back from GitHub and verify its rendered body before posting the remainder.

## GitHub review conversation resolution

- A workflow label or written status such as `Closed` does not replace GitHub's native Resolve Conversation action.
- After the independent reviewer accepts a finding, resolve its GitHub review thread through the native thread-resolution API, equivalent to clicking **Resolve conversation**.
- Before completing or merging the pull request, query all review threads with thread-aware GitHub GraphQL data, follow cursor pagination until `pageInfo.hasNextPage` is false, and confirm every accepted or no-finding conversation reports `isResolved: true`.
- Do not claim review completion while any applicable conversation remains natively unresolved.

## VirtualBox test appliance

- The maintained test VM name is `IDWP-Debian12`.
- Use NAT with host TCP port `2222` forwarded to guest SSH port `22`.
- Allocate at least 2 CPUs, 4 GiB RAM, and 32 GiB dynamically allocated disk.
- Keep credentials out of source control. Test credentials are local-only and must be changed before reuse beyond the disposable test appliance.
- Store the `idwp` guest credential as a Generic Credential in Windows
  Credential Manager under the exact target
  `IDWP/VirtualBox/IDWP-Debian12/idwp`. Do not persist it in a repository,
  script, plaintext file, implementation plan, terminal transcript, or
  documentation.
- Immediately create or update that Credential Manager entry whenever the
  appliance is created or its password is reset, then prove both a credential
  read and an authenticated VirtualBox Guest Control command before relying on
  the appliance.
- If the credential is unavailable, reset the disposable guest credential
  through Debian recovery, replace the Credential Manager entry, and record
  only the recovery event and target name—not the secret.
- Take a `clean-os` snapshot after OS installation and a `epic-1-verified` snapshot only after successful bootstrap and validation.

## Licensing safety

- Do not describe the upstream license as OSI-approved open source.
- Treat upstream's `LICENSE` as a custom SSPL-derived source-available license unless qualified legal counsel determines otherwise.
- Do not remove or weaken the upstream license, service-source obligations, competitive-service restriction, copyright, or trademark terms.
- Before external hosted-service use, distribution, or commercial launch, require legal review and record the outcome in `LICENSE_COMPLIANCE.md`.
