#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY_URL="https://github.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP.git"
PROJECT_REF="feature/epic-1-baseline"
DESTINATION="${HOME}/src/IndependentDeveloperWorkflowMCP"
SKIP_BUILD=0
SKIP_AUDIT=0

usage() {
    cat <<'EOF'
Usage: scripts/bootstrap-linux.sh [options]

Install Linux development dependencies, clone/update IDWP, and validate it.

Options:
  --repo URL          Repository to clone.
  --ref REF           Branch, tag, or commit to check out.
  --destination PATH  Checkout destination.
  --skip-build        Install and copy only.
  --skip-audit        Skip cargo-audit installation and execution.
  --help              Show this help.
EOF
}

while (($#)); do
    case "$1" in
        --repo) REPOSITORY_URL="${2:?--repo requires a value}"; shift 2 ;;
        --ref) PROJECT_REF="${2:?--ref requires a value}"; shift 2 ;;
        --destination) DESTINATION="${2:?--destination requires a value}"; shift 2 ;;
        --skip-build) SKIP_BUILD=1; shift ;;
        --skip-audit) SKIP_AUDIT=1; shift ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This bootstrap supports Linux only." >&2
    exit 1
fi

if command -v apt-get >/dev/null 2>&1; then
    if [[ "${EUID}" -eq 0 ]]; then
        SUDO=()
    elif command -v sudo >/dev/null 2>&1; then
        SUDO=(sudo)
    else
        echo "apt-get requires root or sudo." >&2
        exit 1
    fi

    "${SUDO[@]}" apt-get update
    "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential ca-certificates clang cmake curl git jq \
        libssl-dev pkg-config unzip
else
    echo "Unsupported distribution: apt-get is required (Debian/Ubuntu)." >&2
    exit 1
fi

if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs \
        | sh -s -- -y --profile minimal
fi

export PATH="${HOME}/.cargo/bin:${HOME}/.bun/bin:${PATH}"
rustup toolchain install stable --profile minimal --component clippy --component rustfmt
rustup default stable

if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
fi
export PATH="${HOME}/.bun/bin:${PATH}"

if [[ -e "${DESTINATION}" && ! -d "${DESTINATION}/.git" ]]; then
    echo "Destination exists but is not a Git checkout: ${DESTINATION}" >&2
    exit 1
fi

if [[ ! -d "${DESTINATION}/.git" ]]; then
    mkdir -p "$(dirname "${DESTINATION}")"
    git clone --branch "${PROJECT_REF}" --single-branch "${REPOSITORY_URL}" "${DESTINATION}"
else
    if [[ -n "$(git -C "${DESTINATION}" status --porcelain)" ]]; then
        echo "Refusing to update a checkout with local changes: ${DESTINATION}" >&2
        exit 1
    fi
    git -C "${DESTINATION}" fetch origin "${PROJECT_REF}"
    git -C "${DESTINATION}" checkout "${PROJECT_REF}"
    git -C "${DESTINATION}" merge --ff-only FETCH_HEAD
fi

if ((SKIP_BUILD)); then
    echo "Bootstrap complete at ${DESTINATION}; build skipped."
    exit 0
fi

(
    cd "${DESTINATION}/web"
    bun install --frozen-lockfile
    bun run build
)

(
    cd "${DESTINATION}"
    cargo fmt -- --check
    cargo build --locked
    cargo test --locked
    cargo clippy --locked -- -D warnings

    if ((!SKIP_AUDIT)); then
        command -v cargo-audit >/dev/null 2>&1 || cargo install cargo-audit --locked
        cargo audit \
            --ignore RUSTSEC-2026-0097 \
            --ignore RUSTSEC-2026-0098 \
            --ignore RUSTSEC-2026-0099 \
            --ignore RUSTSEC-2026-0104 \
            --ignore RUSTSEC-2026-0118 \
            --ignore RUSTSEC-2026-0119
    fi
)

printf 'Bootstrap and validation complete.\nRevision: %s\nPath: %s\n' \
    "$(git -C "${DESTINATION}" rev-parse HEAD)" "${DESTINATION}"
