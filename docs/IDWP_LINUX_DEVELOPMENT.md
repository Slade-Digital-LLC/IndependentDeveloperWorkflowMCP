# IDWP Linux Development Setup

The canonical development environment is a clean Debian 12 or supported Ubuntu installation. The bootstrap installs system packages and pinned toolchains, clones the organization fork, and runs the upstream frontend/Rust build, test, format, lint, and advisory subset.

```bash
curl -fsSL https://raw.githubusercontent.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP/master/scripts/bootstrap-linux.sh \
  -o /tmp/idwp-bootstrap.sh
bash /tmp/idwp-bootstrap.sh \
  --ref master \
  --destination "$HOME/src/IndependentDeveloperWorkflowMCP"
```

For a pinned reproducibility run, pass a full reachable commit SHA with `--ref`; the checkout will be detached at that exact commit. Branch refs remain on a local tracking branch. Existing checkouts are updated only when clean, and their `origin` must match `--repo`. The script refuses to overwrite a non-Git destination, local changes, or a checkout pointed at another repository.

Installed prerequisites:

- Git, curl, CA certificates, jq, unzip;
- C/C++ build tools, Clang, CMake, `pkg-config`, and OpenSSL headers;
- Rust 1.97.1 through rustup with rustfmt and Clippy, also pinned by `rust-toolchain.toml`;
- Bun for the Svelte/Vite frontend;
- `cargo-audit` unless `--skip-audit` is selected.

Useful modes:

```bash
# Install dependencies and clone without compiling.
bash scripts/bootstrap-linux.sh --skip-build

# Run deterministic build/tests while omitting the slow advisory-tool install.
bash scripts/bootstrap-linux.sh --skip-audit
```

The script intentionally does not install API tokens, AI credentials, wshm Pro license material, production services, or databases. Upstream OSS uses bundled SQLite. Live-provider and Pro-feature tests require separately authorized credentials and licensing.

`bun run check` is intentionally not part of the Epic 1 bootstrap because the pinned, unmodified upstream fails it with 12 TypeScript errors and 5 warnings, while upstream CI runs `bun run build`. The failure is retained as due-diligence evidence, not hidden or repaired during the no-feature baseline epic.
