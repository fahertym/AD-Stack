//! Unit tests for AD-Stack components

#[cfg(test)]
mod config_tests {
    use ad_stack::config::Config;

    #[test]
    fn test_default_config() {
        let config = Config::default();
        assert_eq!(config.server.host, "0.0.0.0");
        assert_eq!(config.server.port, 8080);
        assert_eq!(config.services.samba.domain, "ADSTACK");
        assert_eq!(config.services.samba.realm, "ADSTACK.LOCAL");
    }
}

#[cfg(test)]
mod orchestration_tests {
    use ad_stack::orchestration::Orchestrator;

    #[tokio::test]
    async fn test_orchestrator_initialization() {
        let mut orchestrator = Orchestrator::new();
        assert!(orchestrator.initialize().await.is_ok());
        
        let services = orchestrator.get_service_status();
        assert!(services.contains_key("samba"));
        assert!(services.contains_key("dns"));
        assert!(services.contains_key("pki"));
    }

    #[tokio::test]
    async fn test_service_registration() {
        let mut orchestrator = Orchestrator::new();
        orchestrator.register_service("test-service".to_string());
        
        let services = orchestrator.get_service_status();
        assert!(services.contains_key("test-service"));
    }
}