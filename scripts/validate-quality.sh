#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ADVISORY=1

if [[ "${1:-}" == "--skip-advisory" ]]; then
    RUN_ADVISORY=0
    shift
fi
if (($#)); then
    echo "Usage: scripts/validate-quality.sh [--skip-advisory]" >&2
    exit 2
fi

command -v cargo >/dev/null || { echo "cargo is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

cd "${ROOT}"
cargo metadata --locked --format-version 1 >/dev/null
cargo fmt --all -- --check
cargo build --workspace --all-targets --locked
cargo test --workspace --locked
cargo clippy --workspace --all-targets --locked -- -D warnings
python3 -m unittest discover -s scripts/tests -p 'test_*.py'

if ((RUN_ADVISORY)); then
    command -v cargo-audit >/dev/null || {
        echo "cargo-audit 0.22.2 is required" >&2
        exit 1
    }
    case "$(cargo audit --version)" in
        "cargo-audit 0.22.2"*) ;;
        *) echo "cargo-audit 0.22.2 is required" >&2; exit 1 ;;
    esac
    cargo audit \
        --ignore RUSTSEC-2026-0097 \
        --ignore RUSTSEC-2026-0098 \
        --ignore RUSTSEC-2026-0099 \
        --ignore RUSTSEC-2026-0104 \
        --ignore RUSTSEC-2026-0118 \
        --ignore RUSTSEC-2026-0119
fi

sbom_path="$(mktemp)"
trap 'rm -f "${sbom_path}"' EXIT
python3 scripts/check-epic3-assets.py --sbom "${sbom_path}"
printf 'IDWP quality gates passed.\n'
