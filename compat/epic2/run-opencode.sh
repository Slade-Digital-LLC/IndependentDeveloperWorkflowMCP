#!/usr/bin/env bash
set -Eeuo pipefail

ROLE="${1:?usage: run-opencode.sh implementation|reviewer PROMPT OUTPUT}"
PROMPT="${2:?prompt is required}"
OUTPUT="${3:?output path is required}"
case "${ROLE}" in implementation|reviewer) ;; *) exit 2 ;; esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXPECTED_VERSION="1.18.7"
ACTUAL_VERSION="$(opencode --version)"
[[ "${ACTUAL_VERSION}" == "${EXPECTED_VERSION}" ]] || {
    echo "OpenCode ${EXPECTED_VERSION} required; found ${ACTUAL_VERSION}." >&2
    exit 1
}

RUNTIME="$(mktemp -d)"
trap 'rm -rf "${RUNTIME}"' EXIT
export OPENCODE_CONFIG="${ROOT}/compat/epic2/profiles/${ROLE}.json"
export XDG_DATA_HOME="${RUNTIME}/data"
export XDG_CACHE_HOME="${RUNTIME}/cache"
export XDG_STATE_HOME="${RUNTIME}/state"

timeout --signal=TERM --kill-after=5s 120s \
    opencode run --pure --format json --title "idwp-epic2-${ROLE}" \
    "${PROMPT}" >"${OUTPUT}"
