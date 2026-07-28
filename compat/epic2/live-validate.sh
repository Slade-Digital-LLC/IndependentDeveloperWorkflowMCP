#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CRATE="${ROOT}/compat/epic2"
TOKEN="${IDWP_EPIC2_TOKEN:-epic2-test-token}"
OUTPUT="${1:-/tmp/idwp-epic2-live.ndjson}"
ERROR_OUTPUT="${OUTPUT}.stderr"
SERVER_PID=

cleanup() {
    if [[ -n "${SERVER_PID}" ]]; then
        kill "${SERVER_PID}" 2>/dev/null || true
        wait "${SERVER_PID}" 2>/dev/null || true
    fi
}
trap cleanup EXIT

IDWP_EPIC2_TOKEN="${TOKEN}" cargo run --quiet \
    --manifest-path "${CRATE}/Cargo.toml" -- \
    --bind 127.0.0.1:8787 --state "${CRATE}/fixtures/state.json" \
    >/tmp/idwp-epic2-live-server.log 2>&1 &
SERVER_PID=$!
for _ in $(seq 1 120); do
    curl -fsS http://127.0.0.1:8787/health >/dev/null 2>&1 && break
    sleep 0.25
done

OPENCODE_CONFIG="${CRATE}/profiles/implementation.json" \
IDWP_EPIC2_TOKEN="${TOKEN}" \
timeout --signal=TERM --kill-after=5s 120s \
    opencode run --pure --model opencode/big-pickle --format json \
    "Call the idwp_epic2 compatibility_probe tool exactly once with correlation_id live-epic2 and role implementation. Return only the tool result." \
    >"${OUTPUT}" 2>"${ERROR_OUTPUT}"

grep -q '"tool":"idwp_epic2_compatibility_probe"' "${OUTPUT}"
grep -q 'restart-stable-epic-2-fixture' "${OUTPUT}"
grep -q '"type":"step_finish"' "${OUTPUT}"
printf 'Live OpenCode MCP call passed: %s\n' "${OUTPUT}"
