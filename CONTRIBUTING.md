# Contributing to IDWP

Start with `AGENTS.md`, the authoritative specifications under
`docs/idwp-spec`, applicable shared guidelines, and every relevant file under
`Project Specific Guidelines`.

## Branches and review

- Branch features from `develop`; never commit directly to `develop` or
  `master`.
- Keep Epic boundaries explicit in a maintained implementation plan created
  from `docs/implementation_plans/templates/epic-template.md`.
- Map every affected code path to tests and record exact validation.
- Use pull requests, independent review when required, visible same-thread
  finding/fix/recheck discussion, native conversation resolution, and
  paginated resolution verification before merge.

## Local quality gates

On Debian/Ubuntu, the canonical bootstrap installs dependencies and runs all
gates. In an existing configured checkout:

```bash
bash scripts/validate-quality.sh
bash compat/epic2/test-compat.sh
```

The quality script checks locked metadata, formatting, workspace build/tests,
Clippy warnings-as-errors, advisory policy, architecture boundaries, required
notices, sanitized configuration, dependency license metadata, and a generated
CycloneDX SBOM.

## Architecture changes

IDWP dependencies point inward. Classify every new crate and direct internal
edge in `idwp/architecture-tests`; unknown or reversed edges must fail closed.
Do not add domain behavior, provider types, persistence, transports, or UI
logic outside the epic that owns that behavior.

## Upstream changes

Prefer IDWP-owned paths and upstream extension seams. Any upstream-owned change
must be minimal, tested, independently reviewed, and recorded in `PATCHES.md`
with its baseline, purpose, security/license impact, and rebase risk.
