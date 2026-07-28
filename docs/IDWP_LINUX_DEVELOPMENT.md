# IDWP Linux Development Setup

The canonical development environment is a clean Debian 12 or supported Ubuntu installation. The bootstrap installs system packages and toolchains, clones the organization fork, and runs the upstream-quality baseline.

```bash
curl -fsSL https://raw.githubusercontent.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP/feature/epic-1-baseline/scripts/bootstrap-linux.sh \
  -o /tmp/idwp-bootstrap.sh
bash /tmp/idwp-bootstrap.sh \
  --ref feature/epic-1-baseline \
  --destination "$HOME/src/IndependentDeveloperWorkflowMCP"
```

For a pinned reproducibility run, pass the full commit SHA with `--ref`. Existing checkouts are updated only when clean and only by fast-forward. The script refuses to overwrite a non-Git destination or local changes.

Installed prerequisites:

- Git, curl, CA certificates, jq, unzip;
- C/C++ build tools, Clang, CMake, `pkg-config`, and OpenSSL headers;
- stable Rust through rustup with rustfmt and Clippy;
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

