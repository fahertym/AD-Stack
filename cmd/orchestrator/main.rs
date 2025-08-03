//! AD-Stack Orchestrator - Central service coordinator

use ad_stack::{
    api::create_router,
    config::Config,
    orchestration::Orchestrator,
};
use axum::Router;
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    ad_stack::init_tracing()?;

    tracing::info!("Starting AD-Stack Orchestrator v{}", ad_stack::VERSION);

    // Load configuration
    let config = Config::load()?;
    tracing::info!("Configuration loaded successfully");

    // Initialize orchestrator
    let mut orchestrator = Orchestrator::new();
    orchestrator.initialize().await?;
    tracing::info!("Orchestrator initialized");

    // Create the web service
    let app = create_app();

    // Determine bind address
    let addr = SocketAddr::from(([0, 0, 0, 0], config.server.port));
    tracing::info!("Starting web server on {}", addr);

    // Start the server
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app)
        .await
        .map_err(|e| anyhow::anyhow!("Server error: {}", e))?;

    Ok(())
}

/// Create the main application with middleware
fn create_app() -> Router {
    create_router()
        .layer(
            CorsLayer::new()
                .allow_origin(tower_http::cors::Any)
                .allow_methods(tower_http::cors::Any)
                .allow_headers(tower_http::cors::Any)
        )
        .layer(TraceLayer::new_for_http())
}