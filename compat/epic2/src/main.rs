use std::{net::SocketAddr, path::PathBuf, sync::Arc};

use anyhow::Context;
use axum::{
    Router,
    extract::{Request, State},
    http::StatusCode,
    middleware::{self, Next},
    response::Response,
    routing::get,
};
use clap::Parser;
use idwp_epic2_compat::{CompatibilityServer, bearer_token};
use rmcp::transport::streamable_http_server::{
    StreamableHttpServerConfig, StreamableHttpService, session::local::LocalSessionManager,
};
use tokio_util::sync::CancellationToken;

#[derive(Parser)]
struct Args {
    #[arg(long, env = "IDWP_EPIC2_BIND", default_value = "127.0.0.1:8787")]
    bind: SocketAddr,
    #[arg(long, env = "IDWP_EPIC2_STATE")]
    state: PathBuf,
    #[arg(long, env = "IDWP_EPIC2_TOKEN")]
    token: String,
}

#[derive(Clone)]
struct AuthState(Arc<str>);

async fn authorize(
    State(expected): State<AuthState>,
    request: Request,
    next: Next,
) -> Result<Response, StatusCode> {
    match bearer_token(request.headers()) {
        Some(actual) if actual.as_bytes() == expected.0.as_bytes() => Ok(next.run(request).await),
        _ => Err(StatusCode::UNAUTHORIZED),
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();
    let args = Args::parse();
    if args.token.trim().is_empty() {
        anyhow::bail!("IDWP_EPIC2_TOKEN must not be empty");
    }
    let cancellation = CancellationToken::new();
    let state_path = args.state.clone();
    let service = StreamableHttpService::new(
        move || Ok(CompatibilityServer::new(state_path.clone())),
        LocalSessionManager::default().into(),
        StreamableHttpServerConfig::default().with_cancellation_token(cancellation.child_token()),
    );
    let protected =
        Router::new()
            .nest_service("/mcp", service)
            .layer(middleware::from_fn_with_state(
                AuthState(Arc::from(args.token)),
                authorize,
            ));
    let app = Router::new()
        .route("/health", get(|| async { "ok" }))
        .merge(protected);
    let listener = tokio::net::TcpListener::bind(args.bind)
        .await
        .with_context(|| format!("failed to bind {}", args.bind))?;
    tracing::info!(address = %args.bind, "Epic 2 MCP compatibility server ready");
    axum::serve(listener, app)
        .with_graceful_shutdown(async move {
            let _ = tokio::signal::ctrl_c().await;
            cancellation.cancel();
        })
        .await?;
    Ok(())
}
