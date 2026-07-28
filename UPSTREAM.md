# Upstream Baseline

## Identity

- Upstream: `https://github.com/wshm-dev/wshm`
- Owner: `wshm-dev`
- Default branch: `main`
- Pinned commit: `96a8599996be04acdffbc157a5e4e76a31b6c84f`
- Package version: `wshm-core 0.31.7`
- Latest published release observed on 2026-07-27: `v0.31.7`
- Organization fork: `https://github.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP`

Epic 1 pins the commit rather than a moving branch or release label. The fork was created through GitHub with default-branch-only history and retains GitHub's parent relationship.

## Remotes and branches

```text
origin    https://github.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP.git
upstream  https://github.com/wshm-dev/wshm.git
```

IDWP uses `master` for production, `develop` for integration, and feature/release/hotfix branches for changes. Upstream continues to use `main`; do not rename or force-update `upstream/main`.

## Synchronization procedure

1. Start from a clean, current `develop`.
2. `git fetch upstream --prune --tags`
3. Create `feature/upstream-<version>` from `develop`.
4. Inspect upstream license, dependency, schema, API, provider, Pro-boundary, and security changes.
5. Merge `upstream/main` without rewriting history.
6. Update the pinned SHA, inventory, license report, patch ledger, and install dependencies.
7. Run frontend checks/build, Rust format/build/test/Clippy, advisory/license scans, and the clean Linux VM suite.
8. Complete independent review before merging through a pull request.

Never rebase or force-push shared IDWP branches. The GitHub fork relationship and explicit upstream remote provide fetchability without rewriting history.

## Baseline source map

- `src/ai`: AI provider selection, prompts, schemas, and local backends.
- `src/git_provider`: GitHub, GitLab, Gitea/Forgejo, and Azure DevOps adapters.
- `src/github`: mature GitHub-specific client, sync, issue, pull-request, and Git helpers.
- `src/db`: SQLite access and in-code migrations.
- `src/pipelines`: triage, PR analysis/health, queue scoring, backup, context, and other workflows.
- `src/daemon`: scheduling, polling, webhook/API server, and embedded web serving.
- `src/secrets`, `src/vault`, `src/auth`: encrypted secrets, optional vaults, and local web authentication.
- `web`: Svelte 5/SvelteKit/Vite/Tailwind dashboard compiled to static embedded assets.
- `deploy`: Kubernetes/Helm/Kustomize materials.
- `Dockerfile`, `docker-compose.yml`, `install.sh`: upstream deployment/install paths.
- `.github/workflows`: upstream build, test, security, smoke, and release automation.

