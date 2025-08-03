//! Configuration module for AD-Stack
//! 
//! Handles application configuration from files and environment variables

use serde::{Deserialize, Serialize};
use std::path::Path;

/// Main application configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub logging: LoggingConfig,
    pub services: ServicesConfig,
}

/// Server configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub tls_enabled: bool,
    pub tls_cert_path: Option<String>,
    pub tls_key_path: Option<String>,
}

/// Database configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatabaseConfig {
    pub url: String,
    pub max_connections: u32,
    pub timeout_seconds: u64,
}

/// Logging configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LoggingConfig {
    pub level: String,
    pub file_path: Option<String>,
    pub rotation: bool,
}

/// Services configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServicesConfig {
    pub samba: SambaConfig,
    pub dns: DnsConfig,
    pub pki: PkiConfig,
}

/// Samba service configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SambaConfig {
    pub domain: String,
    pub realm: String,
    pub admin_password: String,
    pub config_path: String,
}

/// DNS service configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DnsConfig {
    pub forwarders: Vec<String>,
    pub zone_file_path: String,
}

/// PKI service configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PkiConfig {
    pub ca_cert_path: String,
    pub ca_key_path: String,
    pub cert_validity_days: u32,
}

impl Config {
    /// Load configuration from file
    pub fn from_file<P: AsRef<Path>>(path: P) -> anyhow::Result<Self> {
        let content = std::fs::read_to_string(path)?;
        let config: Config = serde_yaml::from_str(&content)?;
        Ok(config)
    }

    /// Load configuration with defaults
    pub fn load() -> anyhow::Result<Self> {
        // Try to load from default locations
        let config_paths = [
            "/etc/ad-stack/config.yaml",
            "/usr/local/etc/ad-stack/config.yaml",
            "./config.yaml",
        ];

        for path in &config_paths {
            if Path::new(path).exists() {
                return Self::from_file(path);
            }
        }

        // Return default configuration if no file found
        Ok(Self::default())
    }
}

impl Default for Config {
    fn default() -> Self {
        Self {
            server: ServerConfig {
                host: "0.0.0.0".to_string(),
                port: 8080,
                tls_enabled: false,
                tls_cert_path: None,
                tls_key_path: None,
            },
            database: DatabaseConfig {
                url: "postgresql://ad-stack:password@localhost/ad_stack".to_string(),
                max_connections: 10,
                timeout_seconds: 30,
            },
            logging: LoggingConfig {
                level: "info".to_string(),
                file_path: Some("/var/log/ad-stack/app.log".to_string()),
                rotation: true,
            },
            services: ServicesConfig {
                samba: SambaConfig {
                    domain: "ADSTACK".to_string(),
                    realm: "ADSTACK.LOCAL".to_string(),
                    admin_password: "changeme".to_string(),
                    config_path: "/etc/samba/smb.conf".to_string(),
                },
                dns: DnsConfig {
                    forwarders: vec!["8.8.8.8".to_string(), "8.8.4.4".to_string()],
                    zone_file_path: "/var/lib/samba/private/dns".to_string(),
                },
                pki: PkiConfig {
                    ca_cert_path: "/etc/ad-stack/pki/ca.crt".to_string(),
                    ca_key_path: "/etc/ad-stack/pki/ca.key".to_string(),
                    cert_validity_days: 365,
                },
            },
        }
    }
}