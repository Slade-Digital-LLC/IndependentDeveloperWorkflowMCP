use std::{fs, path::PathBuf};

use rmcp::{
    ErrorData as McpError, RoleServer, ServerHandler, handler::server::wrapper::Parameters,
    model::*, schemars, tool, tool_handler, tool_router,
};
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};

pub const SERVER_NAME: &str = "idwp-epic2-compat";
pub const STATE_RESOURCE_URI: &str = "idwp://compatibility/state";

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
pub struct CompatibilityState {
    pub revision: u64,
    pub value: String,
}

#[derive(Clone, Debug, Deserialize, schemars::JsonSchema)]
pub struct ProbeRequest {
    pub correlation_id: String,
    pub role: String,
}

#[derive(Clone, Debug, Deserialize, schemars::JsonSchema)]
pub struct ErrorRequest {
    pub message: String,
}

#[derive(Clone)]
pub struct CompatibilityServer {
    state_path: PathBuf,
}

#[tool_router]
impl CompatibilityServer {
    pub fn new(state_path: PathBuf) -> Self {
        Self { state_path }
    }

    pub fn load_state(&self) -> Result<CompatibilityState, McpError> {
        let raw = fs::read_to_string(&self.state_path).map_err(|error| {
            McpError::internal_error(
                "compatibility state unavailable",
                Some(json!({ "kind": error.kind().to_string() })),
            )
        })?;
        serde_json::from_str(&raw)
            .map_err(|_| McpError::internal_error("compatibility state is invalid", None))
    }

    #[tool(description = "Return restart-stable compatibility state and correlation metadata")]
    fn compatibility_probe(
        &self,
        Parameters(request): Parameters<ProbeRequest>,
    ) -> Result<CallToolResult, McpError> {
        if request.correlation_id.trim().is_empty() {
            return Err(McpError::invalid_params("correlation_id is required", None));
        }
        if !matches!(request.role.as_str(), "implementation" | "reviewer") {
            return Err(McpError::invalid_params(
                "role must be implementation or reviewer",
                None,
            ));
        }
        let state = self.load_state()?;
        Ok(CallToolResult::success(vec![ContentBlock::text(
            json!({
                "correlation_id": request.correlation_id,
                "role": request.role,
                "state": state,
            })
            .to_string(),
        )]))
    }

    #[tool(description = "Return a deterministic protocol error for compatibility testing")]
    fn forced_error(
        &self,
        Parameters(request): Parameters<ErrorRequest>,
    ) -> Result<CallToolResult, McpError> {
        Err(McpError::invalid_params(
            "forced compatibility error",
            Some(json!({ "message_length": request.message.len() })),
        ))
    }
}

#[tool_handler]
impl ServerHandler for CompatibilityServer {
    fn get_info(&self) -> ServerInfo {
        ServerInfo::new(
            ServerCapabilities::builder()
                .enable_tools()
                .enable_resources()
                .build(),
        )
        .with_server_info(Implementation::new(SERVER_NAME, env!("CARGO_PKG_VERSION")))
        .with_protocol_version(ProtocolVersion::V_2025_06_18)
        .with_instructions("Epic 2 compatibility prototype; no production workflow logic.")
    }

    async fn list_resources(
        &self,
        _request: Option<PaginatedRequestParams>,
        _context: rmcp::service::RequestContext<RoleServer>,
    ) -> Result<ListResourcesResult, McpError> {
        Ok(ListResourcesResult::with_all_items(vec![Resource::new(
            STATE_RESOURCE_URI,
            "Restart-stable compatibility fixture",
        )]))
    }

    async fn read_resource(
        &self,
        request: ReadResourceRequestParams,
        _context: rmcp::service::RequestContext<RoleServer>,
    ) -> Result<ReadResourceResult, McpError> {
        if request.uri != STATE_RESOURCE_URI {
            return Err(McpError::resource_not_found(
                "resource not found",
                Some(json!({ "uri": request.uri })),
            ));
        }
        let state = self.load_state()?;
        Ok(ReadResourceResult::new(vec![ResourceContents::text(
            serde_json::to_string(&state).expect("state is serializable"),
            STATE_RESOURCE_URI,
        )]))
    }
}

pub fn bearer_token(headers: &axum::http::HeaderMap) -> Option<&str> {
    headers
        .get(axum::http::header::AUTHORIZATION)?
        .to_str()
        .ok()?
        .strip_prefix("Bearer ")
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
pub struct TokenUsage {
    pub input: u64,
    pub output: u64,
    pub reasoning: u64,
    pub cache_read: u64,
    pub cache_write: u64,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
pub struct NormalizedTelemetry {
    pub schema_version: u32,
    pub event_type: String,
    pub session_id: String,
    pub message_id: Option<String>,
    pub requested_model: Option<String>,
    pub actual_provider: Option<String>,
    pub actual_model: Option<String>,
    pub tokens: Option<TokenUsage>,
    pub cost_decimal: Option<String>,
    pub retry_attempt: Option<u64>,
    pub retryable: Option<bool>,
    pub parent_session_id: Option<String>,
    pub child_session_id: Option<String>,
    pub selected_model: Option<String>,
    pub terminal_error: Option<String>,
    pub quality: String,
    pub missing_fields: Vec<String>,
}

pub fn normalize_opencode_event(
    event: &Value,
    requested_model: Option<String>,
) -> Result<NormalizedTelemetry, String> {
    let event_type = event
        .get("type")
        .and_then(Value::as_str)
        .ok_or("missing event type")?;
    let properties = event.get("properties");
    let part = event.get("part");
    let session_id = event
        .get("sessionID")
        .or_else(|| properties.and_then(|value| value.get("sessionID")))
        .and_then(Value::as_str)
        .ok_or("missing sessionID")?
        .to_owned();
    let tokens = part
        .and_then(|part| part.get("tokens"))
        .or_else(|| properties.and_then(|value| value.get("tokens")))
        .map(|tokens| {
            Ok::<TokenUsage, String>(TokenUsage {
                input: required_u64(tokens, "input")?,
                output: required_u64(tokens, "output")?,
                reasoning: required_u64(tokens, "reasoning")?,
                cache_read: required_u64(
                    tokens
                        .get("cache")
                        .ok_or_else(|| "missing token cache".to_owned())?,
                    "read",
                )?,
                cache_write: required_u64(
                    tokens
                        .get("cache")
                        .ok_or_else(|| "missing token cache".to_owned())?,
                    "write",
                )?,
            })
        })
        .transpose()?;
    let cost_decimal = part
        .and_then(|part| part.get("cost"))
        .or_else(|| properties.and_then(|value| value.get("cost")))
        .and_then(Value::as_number)
        .map(ToString::to_string);
    let actual_provider = event
        .pointer("/providerID")
        .or_else(|| event.pointer("/part/providerID"))
        .or_else(|| event.pointer("/properties/model/providerID"))
        .and_then(Value::as_str)
        .map(str::to_owned);
    let actual_model = event
        .pointer("/modelID")
        .or_else(|| event.pointer("/part/modelID"))
        .or_else(|| event.pointer("/properties/model/id"))
        .and_then(Value::as_str)
        .map(str::to_owned);
    let retry_attempt = event.pointer("/properties/attempt").and_then(Value::as_u64);
    let retryable = event
        .pointer("/properties/retryable")
        .and_then(Value::as_bool);
    let parent_session_id = event
        .pointer("/part/state/metadata/parentSessionId")
        .and_then(Value::as_str)
        .map(str::to_owned);
    let child_session_id = event
        .pointer("/part/state/metadata/sessionId")
        .and_then(Value::as_str)
        .map(str::to_owned);
    let selected_model = event
        .pointer("/part/state/metadata/model")
        .and_then(Value::as_str)
        .map(str::to_owned);
    let terminal_error = event
        .pointer("/error/name")
        .or_else(|| event.pointer("/part/error/name"))
        .and_then(Value::as_str)
        .map(str::to_owned);
    let mut missing_fields = Vec::new();
    if actual_provider.is_none() {
        missing_fields.push("actual_provider".to_owned());
    }
    if actual_model.is_none() {
        missing_fields.push("actual_model".to_owned());
    }
    if tokens.is_none() {
        missing_fields.push("tokens".to_owned());
    }
    if cost_decimal.is_none() {
        missing_fields.push("cost".to_owned());
    }
    let quality = if missing_fields.is_empty() {
        "Complete"
    } else if tokens.is_some() {
        "Partial"
    } else {
        "Unavailable"
    };
    Ok(NormalizedTelemetry {
        schema_version: 1,
        event_type: event_type.to_owned(),
        session_id,
        message_id: part
            .and_then(|part| part.get("messageID"))
            .or_else(|| properties.and_then(|value| value.get("assistantMessageID")))
            .and_then(Value::as_str)
            .map(str::to_owned),
        requested_model,
        actual_provider,
        actual_model,
        tokens,
        cost_decimal,
        retry_attempt,
        retryable,
        parent_session_id,
        child_session_id,
        selected_model,
        terminal_error,
        quality: quality.to_owned(),
        missing_fields,
    })
}

fn required_u64(value: &Value, field: &str) -> Result<u64, String> {
    value
        .get(field)
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("missing or invalid {field} token count"))
}

#[cfg(test)]
mod tests {
    use std::io::Write;

    use super::*;

    #[test]
    fn telemetry_preserves_machine_readable_usage_and_missing_model() {
        let event: Value =
            serde_json::from_str(include_str!("../fixtures/opencode-step-finish.json")).unwrap();
        let telemetry =
            normalize_opencode_event(&event, Some("opencode/test-model".to_owned())).unwrap();
        assert_eq!(telemetry.session_id, "ses_epic2_implementation");
        assert_eq!(telemetry.cost_decimal.as_deref(), Some("0.00125"));
        assert_eq!(telemetry.quality, "Partial");
        assert!(
            telemetry
                .missing_fields
                .contains(&"actual_model".to_owned())
        );
    }

    #[test]
    fn prose_cannot_supply_authoritative_telemetry() {
        let event = json!({
            "type": "text",
            "sessionID": "ses_reviewer",
            "part": { "text": "I used model X and 500 tokens." }
        });
        let telemetry = normalize_opencode_event(&event, None).unwrap();
        assert_eq!(telemetry.actual_model, None);
        assert_eq!(telemetry.tokens, None);
        assert_eq!(telemetry.quality, "Unavailable");
    }

    #[test]
    fn missing_session_is_schema_drift() {
        assert!(normalize_opencode_event(&json!({"type": "step_finish"}), None).is_err());
    }

    #[test]
    fn restart_state_is_loaded_from_authoritative_file_each_time() {
        let mut file = tempfile::NamedTempFile::new().unwrap();
        write!(file, r#"{{"revision":1,"value":"before"}}"#).unwrap();
        let server = CompatibilityServer::new(file.path().to_owned());
        assert_eq!(server.load_state().unwrap().value, "before");
        std::fs::write(file.path(), r#"{"revision":2,"value":"after"}"#).unwrap();
        assert_eq!(server.load_state().unwrap().value, "after");
    }

    #[test]
    fn server_step_events_normalize_route_and_correlated_usage() {
        let started: Value =
            serde_json::from_str(include_str!("../fixtures/opencode-step-started.json")).unwrap();
        let start = normalize_opencode_event(&started, Some("requested/model".to_owned())).unwrap();
        assert_eq!(start.session_id, "ses_epic2_implementation");
        assert_eq!(start.message_id.as_deref(), Some("msg_1"));
        assert_eq!(start.requested_model.as_deref(), Some("requested/model"));
        assert_eq!(start.actual_provider.as_deref(), Some("opencode"));
        assert_eq!(start.actual_model.as_deref(), Some("big-pickle"));

        let ended: Value =
            serde_json::from_str(include_str!("../fixtures/opencode-step-ended.json")).unwrap();
        let end = normalize_opencode_event(&ended, None).unwrap();
        assert_eq!(end.session_id, start.session_id);
        assert_eq!(end.message_id, start.message_id);
        assert_eq!(end.tokens.unwrap().output, 4);
        assert_eq!(end.cost_decimal.as_deref(), Some("0.00125"));
    }

    #[test]
    fn retry_delegation_and_timeout_fixtures_fail_closed_on_drift() {
        let retry: Value =
            serde_json::from_str(include_str!("../fixtures/opencode-retry.json")).unwrap();
        let retry = normalize_opencode_event(&retry, None).unwrap();
        assert_eq!(retry.session_id, "ses_epic2_implementation");
        assert_eq!(retry.retry_attempt, Some(2));
        assert_eq!(retry.retryable, Some(true));

        let delegation: Value =
            serde_json::from_str(include_str!("../fixtures/opencode-delegation.json")).unwrap();
        let delegation = normalize_opencode_event(&delegation, None).unwrap();
        assert_eq!(
            delegation.parent_session_id.as_deref(),
            Some("ses_epic2_implementation")
        );
        assert_eq!(
            delegation.child_session_id.as_deref(),
            Some("ses_epic2_child")
        );
        assert_ne!(delegation.parent_session_id, delegation.child_session_id);
        assert_eq!(
            delegation.selected_model.as_deref(),
            Some("opencode/big-pickle")
        );

        let timeout: Value =
            serde_json::from_str(include_str!("../fixtures/opencode-timeout.json")).unwrap();
        let timeout = normalize_opencode_event(&timeout, None).unwrap();
        assert_eq!(timeout.session_id, "ses_epic2_timeout");
        assert_eq!(timeout.terminal_error.as_deref(), Some("AbortError"));
    }

    #[test]
    fn fixture_provenance_pins_observed_opencode_contract() {
        let provenance: Value =
            serde_json::from_str(include_str!("../fixtures/provenance.json")).unwrap();
        assert_eq!(provenance["opencode_version"], "1.18.7");
        assert_eq!(
            provenance["tag_commit"],
            "02981844b88aed33f06f1527da6c58d137975069"
        );
        let fixtures = provenance["fixtures"].as_array().unwrap();
        assert_eq!(fixtures.len(), 6);
        assert!(fixtures.iter().all(|item| item["source"].is_string()));
    }
}
