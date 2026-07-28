#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY_URL="https://github.com/Slade-Digital-LLC/IndependentDeveloperWorkflowMCP.git"
PROJECT_REF="master"
DESTINATION="${HOME}/src/IndependentDeveloperWorkflowMCP"
RUST_TOOLCHAIN="1.97.1"
OPENCODE_VERSION="1.18.7"
CARGO_AUDIT_VERSION="0.22.2"
OPENCODE_LINUX_X64_SHA256="cb5d9d6d2f8fbef0a9c975ed4494f73b2a62f4e4ffd508bcc3212da4fa76c3da"
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

normalize_repository_url() {
    printf '%s' "$1" \
        | sed -E 's#^git@([^:]+):#\1/#; s#^[a-zA-Z]+://##; s#/*$##; s#\.git$##' \
        | tr '[:upper:]' '[:lower:]'
}

checkout_requested_ref() {
    local checkout_path="$1"
    local existing_checkout="$2"

    if git ls-remote --exit-code --heads "${REPOSITORY_URL}" \
        "refs/heads/${PROJECT_REF}" >/dev/null 2>&1; then
        if ((existing_checkout)) &&
            [[ "$(git -C "${checkout_path}" rev-parse \
                --is-shallow-repository)" == "true" ]]; then
            git -C "${checkout_path}" fetch --unshallow origin
        fi

        git -C "${checkout_path}" fetch origin \
            "refs/heads/${PROJECT_REF}:refs/remotes/origin/${PROJECT_REF}"

        if ((existing_checkout)) &&
            git -C "${checkout_path}" show-ref --verify --quiet \
                "refs/heads/${PROJECT_REF}"; then
            git -C "${checkout_path}" checkout "${PROJECT_REF}"
            if ! git -C "${checkout_path}" merge-base --is-ancestor \
                "${PROJECT_REF}" "origin/${PROJECT_REF}"; then
                echo "Local branch has commits not present in origin/${PROJECT_REF}; refusing to discard history." >&2
                exit 1
            fi
            git -C "${checkout_path}" merge --ff-only "origin/${PROJECT_REF}"
        else
            git -C "${checkout_path}" checkout -b "${PROJECT_REF}" \
                --track "origin/${PROJECT_REF}"
        fi
    else
        git -C "${checkout_path}" fetch --depth 1 origin "${PROJECT_REF}"
        git -C "${checkout_path}" checkout --detach FETCH_HEAD
    fi
}

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
        libssl-dev pkg-config python3 unzip
else
    echo "Unsupported distribution: apt-get is required (Debian/Ubuntu)." >&2
    exit 1
fi

if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs \
        | sh -s -- -y --profile minimal
fi

export PATH="${HOME}/.cargo/bin:${HOME}/.bun/bin:${PATH}"
rustup toolchain install "${RUST_TOOLCHAIN}" --profile minimal \
    --component clippy --component rustfmt
rustup default "${RUST_TOOLCHAIN}"

if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
fi
export PATH="${HOME}/.bun/bin:${PATH}"

export PATH="${HOME}/.local/bin:${PATH}"
if ! command -v opencode >/dev/null 2>&1 ||
    [[ "$(opencode --version)" != "${OPENCODE_VERSION}" ]]; then
    architecture="$(uname -m)"
    if [[ "${architecture}" != "x86_64" ]]; then
        echo "OpenCode compatibility pin currently supports Linux x86_64 only." >&2
        exit 1
    fi
    opencode_archive="$(mktemp)"
    trap 'rm -f "${opencode_archive}"' EXIT
    curl -fsSL \
        "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" \
        -o "${opencode_archive}"
    printf '%s  %s\n' "${OPENCODE_LINUX_X64_SHA256}" "${opencode_archive}" \
        | sha256sum --check -
    mkdir -p "${HOME}/.local/lib/opencode/${OPENCODE_VERSION}" \
        "${HOME}/.local/bin"
    tar -xzf "${opencode_archive}" \
        -C "${HOME}/.local/lib/opencode/${OPENCODE_VERSION}"
    ln -sfn "${HOME}/.local/lib/opencode/${OPENCODE_VERSION}/opencode" \
        "${HOME}/.local/bin/opencode"
    rm -f "${opencode_archive}"
    trap - EXIT
fi
[[ "$(opencode --version)" == "${OPENCODE_VERSION}" ]] || {
    echo "OpenCode ${OPENCODE_VERSION} installation verification failed." >&2
    exit 1
}

if [[ -e "${DESTINATION}" && ! -d "${DESTINATION}/.git" ]]; then
    echo "Destination exists but is not a Git checkout: ${DESTINATION}" >&2
    exit 1
fi

if [[ ! -d "${DESTINATION}/.git" ]]; then
    mkdir -p "$(dirname "${DESTINATION}")"
    git clone --no-checkout "${REPOSITORY_URL}" "${DESTINATION}"
    checkout_requested_ref "${DESTINATION}" 0
else
    if [[ -n "$(git -C "${DESTINATION}" status --porcelain)" ]]; then
        echo "Refusing to update a checkout with local changes: ${DESTINATION}" >&2
        exit 1
    fi

    actual_origin="$(normalize_repository_url \
        "$(git -C "${DESTINATION}" remote get-url origin)")"
    requested_origin="$(normalize_repository_url "${REPOSITORY_URL}")"
    if [[ "${actual_origin}" != "${requested_origin}" ]]; then
        echo "Existing checkout origin does not match --repo." >&2
        echo "Expected: ${requested_origin}" >&2
        echo "Actual:   ${actual_origin}" >&2
        exit 1
    fi

    checkout_requested_ref "${DESTINATION}" 1
fi

if ((!SKIP_AUDIT)); then
    audit_version=""
    if command -v cargo-audit >/dev/null 2>&1; then
        audit_version="$(cargo-audit --version)"
    fi
    if [[ "${audit_version}" != "cargo-audit ${CARGO_AUDIT_VERSION}"* ]]; then
        cargo install cargo-audit --locked \
            --version "${CARGO_AUDIT_VERSION}" --force
    fi
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
# The upstream Vite build recreates src/web-dist and removes its tracked
# sentinel. Restore the zero-byte marker so a successful build leaves Git clean.
touch "${DESTINATION}/src/web-dist/.gitkeep"

(
    cd "${DESTINATION}"
    if ((!SKIP_AUDIT)); then
        bash scripts/validate-quality.sh
    else
        bash scripts/validate-quality.sh --skip-advisory
    fi
)

(
    cd "${DESTINATION}/compat/epic2"
    cargo fmt -- --check
    cargo build --locked
    cargo test --locked
    cargo clippy --locked -- -D warnings
)

bash "${DESTINATION}/compat/epic2/test-compat.sh"

printf 'Bootstrap and validation complete.\nRevision: %s\nPath: %s\n' \
    "$(git -C "${DESTINATION}" rev-parse HEAD)" "${DESTINATION}"
