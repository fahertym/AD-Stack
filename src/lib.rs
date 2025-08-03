//! AD-Stack: Open-source Active Directory replacement for SMBs
//! 
//! This crate provides the core functionality for AD-Stack, including
//! API endpoints, orchestration logic, and configuration management.

pub mod api;
pub mod config;
pub mod orchestration;

/// Library version
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Initialize tracing for the application
pub fn init_tracing() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_version() {
        assert!(!VERSION.is_empty());
    }
}