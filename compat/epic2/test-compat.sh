#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CRATE="${ROOT}/compat/epic2"
PORT="${IDWP_EPIC2_PORT:-8787}"
TOKEN="${IDWP_EPIC2_TOKEN:-epic2-test-token}"
BASE_URL="http://127.0.0.1:${PORT}"
TMP="$(mktemp -d)"
SERVER_PID=

cleanup() {
    if [[ -n "${SERVER_PID}" ]]; then
        kill "${SERVER_PID}" 2>/dev/null || true
        wait "${SERVER_PID}" 2>/dev/null || true
    fi
    rm -rf "${TMP}"
}
trap cleanup EXIT

start_server() {
    IDWP_EPIC2_TOKEN="${TOKEN}" cargo run --quiet \
        --manifest-path "${CRATE}/Cargo.toml" -- \
        --bind "127.0.0.1:${PORT}" \
        --state "${CRATE}/fixtures/state.json" \
        >"${TMP}/server.log" 2>&1 &
    SERVER_PID=$!
    for _ in $(seq 1 240); do
        if curl -fsS "${BASE_URL}/health" >/dev/null 2>&1; then return; fi
        sleep 0.25
    done
    cat "${TMP}/server.log" >&2
    exit 1
}

stop_server() {
    kill "${SERVER_PID}"
    wait "${SERVER_PID}" 2>/dev/null || true
    SERVER_PID=
}

rpc() {
    local payload="$1"
    local session_header=()
    if [[ -n "${SESSION_ID:-}" ]]; then
        session_header=(-H "Mcp-Session-Id: ${SESSION_ID}")
    fi
    curl -fsS -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json, text/event-stream" \
        "${session_header[@]}" --data "${payload}" "${BASE_URL}/mcp"
}

initialize() {
    local prefix="$1"
    curl -fsS -D "${TMP}/${prefix}-headers" -o "${TMP}/${prefix}-body" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json, text/event-stream" \
        --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"idwp-epic2-test","version":"1"}}}' \
        "${BASE_URL}/mcp"
    SESSION_ID="$(awk 'BEGIN{IGNORECASE=1} /^mcp-session-id:/ {gsub("\r","",$2); print $2}' "${TMP}/${prefix}-headers")"
    [[ -n "${SESSION_ID}" ]]
    rpc '{"jsonrpc":"2.0","method":"notifications/initialized"}' >/dev/null
}

start_server
status="$(curl -sS -o /dev/null -w '%{http_code}' \
    -H 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' \
    "${BASE_URL}/mcp")"
[[ "${status}" == "401" ]]

initialize first
rpc '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | grep -q 'compatibility_probe'
rpc '{"jsonrpc":"2.0","id":3,"method":"resources/list","params":{}}' | grep -q 'idwp://compatibility/state'
rpc '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"compatibility_probe","arguments":{"correlation_id":"corr-before-restart","role":"implementation"}}}' | grep -q 'restart-stable-epic-2-fixture'
rpc '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"forced_error","arguments":{"message":"safe"}}}' | grep -q 'forced compatibility error'

stop_server
start_server
SESSION_ID=
initialize restart
rpc '{"jsonrpc":"2.0","id":7,"method":"resources/read","params":{"uri":"idwp://compatibility/state"}}' | grep -q 'restart-stable-epic-2-fixture'

NO_COLOR=1 OPENCODE_CONFIG="${CRATE}/profiles/implementation.json" \
IDWP_EPIC2_TOKEN="${TOKEN}" opencode mcp list | grep -qi 'connected'

printf 'Epic 2 compatibility tests passed; restart state preserved.\n'
