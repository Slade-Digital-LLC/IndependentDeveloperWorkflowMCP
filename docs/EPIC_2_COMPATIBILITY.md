# Epic 2 OpenCode, MCP, and Telemetry Compatibility

## Decision

Epic 2 pins OpenCode 1.18.7 and the stable official Rust MCP SDK `rmcp`
2.2.0. The compatibility prototype uses authenticated, stateful Streamable
HTTP at `/mcp`. It remains outside the upstream crate and contains no
production workflow logic.

## Version matrix

| Component | Pin | Evidence |
|---|---|---|
| OpenCode | 1.18.7, tag commit `02981844b88aed33f06f1527da6c58d137975069` | Official release and tagged source |
| Linux x64 OpenCode archive | SHA-256 `cb5d9d6d2f8fbef0a9c975ed4494f73b2a62f4e4ffd508bcc3212da4fa76c3da` | GitHub release asset |
| MCP protocol | `2025-06-18` | OpenCode and `rmcp` negotiation |
| Rust MCP SDK | `rmcp` 2.2.0 | Stable official SDK release; 3.0 was beta during the spike |
| Rust | 1.97.1 | Repository toolchain pin |
| Test OS | Debian 12 x86_64 | Maintained VirtualBox appliance |

The OpenCode asset is downloaded from its immutable tagged release, verified
before extraction, installed under a versioned user path, and checked with
`opencode --version`.

## Prototype contract

`compat/epic2` exposes:

- `compatibility_probe`, returning caller correlation, execution role, and
  restart-stable fixture state;
- `forced_error`, returning a deterministic safe protocol error;
- `idwp://compatibility/state`, a bounded resource backed by an external JSON
  fixture.

Bearer authentication is mandatory on every MCP request. The checked-in token
name is an environment substitution, not a credential. OAuth is explicitly
disabled for this test profile so OpenCode does not reinterpret the bearer
header as an OAuth challenge.

The SDK's session manager is intentionally process-local. Authoritative test
state is reloaded from the fixture on each request, demonstrating that an MCP
server restart may invalidate a transport session without losing authoritative
state assumptions.

## OpenCode launcher contract

The supported noninteractive form is:

```bash
OPENCODE_CONFIG=/absolute/profile.json \
OPENCODE_CONFIG_DIR=/absolute/profile-directory \
opencode run \
  --dir /absolute/read-only-or-implementation-worktree \
  --agent idwp-role \
  --model provider/model \
  --format json \
  "bounded prompt"
```

Automation must use `--session <id>` to resume a known session; `--continue`
is not deterministic. Reviewer runs must not use `--auto`. Implementation and
reviewer runs use different configuration paths, data/cache/state directories,
working directories, credentials, titles, and session IDs.

`compat/epic2/run-opencode.sh` enforces the version, bounds execution to 120
seconds, gives each run an isolated OpenCode data directory, and captures
newline-delimited JSON. `reviewer.json` allows repository reads and denies
editing, shell execution, task delegation, web access, and other write-capable
tools. Production process/credential isolation remains an Epic 12 concern.

## OpenCode MCP interface

The pinned remote configuration uses:

```json
{
  "type": "remote",
  "url": "http://127.0.0.1:8787/mcp",
  "oauth": false,
  "headers": {
    "Authorization": "Bearer {env:IDWP_EPIC2_TOKEN}"
  },
  "codemode": false,
  "timeout": 30000
}
```

OpenCode tries Streamable HTTP first and retains a legacy SSE fallback. The
compatibility test requires authenticated initialization, tool and resource
discovery, tool execution, safe errors, a new session after restart, preserved
external state, and a connected `opencode mcp list` result.

## Telemetry contract

`opencode run --format json` emits NDJSON containing `sessionID`, timestamp,
and event types including `tool_use`, `step_start`, `step_finish`, `text`,
`reasoning`, and `error`. A `step_finish.part` supplies token categories and
OpenCode's numeric cost, but does not reliably include actual provider/model.

The preferred supplementary source is the authenticated `opencode serve`
event/session API:

- `session.next.step.started`: session, message, agent, provider, model;
- `session.next.step.ended`: correlation, finish reason, tokens, and cost;
- `session.next.retried` and `session.status`: attempt and retry state;
- task tool metadata: parent and child session IDs plus selected route.

The `/event` SSE stream does not provide a resumable SSE event ID. A consumer
must reconnect, query session/message/status state, and deduplicate using a
normalized event fingerprint. These are compatibility-tested upstream
interfaces, not yet an IDWP production API.

### Quality and fallback

| Field | Source | Quality/fallback |
|---|---|---|
| Session ID | CLI NDJSON and server events | Complete when both correlate |
| Actual provider/model | `session.next.step.started` | Partial/Unavailable if absent; requested route is never substituted |
| Input/output/reasoning/cache tokens | `step_finish` / `step.ended` | Complete when machine-readable |
| Cost | OpenCode numeric event | Preserve decimal text and raw digest; currency/provenance unavailable |
| Delegation | task parent/child metadata plus child step event | Partial until child actual route is observed |
| Retry | retry/status events | Preserve each attempt, including failures |
| wshm correlation | existing agent execution and logs | Unavailable in current upstream at request-level precision |

Existing `src/telemetry.rs` is anonymous product-usage telemetry, and
`src/db/usage.rs` is a coarse call-count surface. Neither is an AI request
ledger. Existing AI client paths do not retain provider usage responses.
Epic 2 therefore classifies wshm request-level model, token, cost, delegation,
retry, and session correlation as unavailable. No natural-language self-report
may fill these fields, and unknown/unpriced cost must never display as zero.

## Validation and drift detection

```bash
cargo fmt --manifest-path compat/epic2/Cargo.toml -- --check
cargo test --manifest-path compat/epic2/Cargo.toml --locked
cargo clippy --manifest-path compat/epic2/Cargo.toml --locked -- -D warnings
bash compat/epic2/test-compat.sh
```

Provenance metadata pins sanitized OpenCode 1.18.7 CLI `step_finish`, server
step-start/step-end/retry, task-delegation, and bounded-cancellation artifacts
to the inspected release and source surface. The production normalizer consumes
those complete fixtures. Tests fail on missing session/message IDs, invalid
token types, missing requested/actual route or delegation correlation, missing
retry/cancellation fields, protocol/tool/resource drift, auth regressions,
restart loss, and OpenCode discovery failure. The canonical Linux bootstrap
runs both the Rust gates and the black-box harness.

The bounded VM-only free-route attempt timed out without a model event. A
second pinned OpenCode 1.18.7 run used the authenticated host environment
against the Rust server in Debian through a temporary loopback-only VirtualBox
forward. It invoked `idwp_epic2_compatibility_probe` exactly once and returned
the restart-stable fixture. A separately isolated reviewer run produced a
different session ID, invoked the read-only probe, and could not access an edit
tool or create the requested test file. The temporary forward was removed
after validation.

## Risks and limitations

- OpenCode server events and session HTTP endpoints are version-pinned observed
  interfaces, not a separately versioned stable telemetry API.
- Cost lacks currency, rate-card version, component provenance, and provider
  request ID.
- The server event stream cannot resume with `Last-Event-ID`.
- The spike uses local HTTP plus bearer authentication. Production remote MCP
  requires TLS and the Epic 8 security design.
- Reviewer permission configuration proves tool restrictions, not a complete
  service/process/credential trust boundary.
- The fixture proves restart behavior but is not production persistence.
- No workflow state, provider administration, gate, merge, attestation,
  dashboard, migration, or production MCP tool is implemented in Epic 2.
