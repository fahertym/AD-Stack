#!/bin/bash

# AD-Stack Installation Script
# This script installs AD-Stack on supported Linux distributions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INSTALL_DIR="/opt/ad-stack"
CONFIG_DIR="/etc/ad-stack"
DATA_DIR="/var/lib/ad-stack"
LOG_DIR="/var/log/ad-stack"
USER="ad-stack"
GROUP="ad-stack"
DOMAIN=""
REALM=""
ADMIN_PASSWORD=""
SERVER_IP=""
SKIP_PROMPTS=false
ENABLE_MONITORING=false

# Functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

check_system() {
    # Check OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        error "Cannot determine operating system"
    fi

    # Check supported OS
    case $OS in
        ubuntu)
            if [[ ! "$VERSION" =~ ^(20.04|22.04|24.04)$ ]]; then
                warn "Unsupported Ubuntu version: $VERSION. Supported: 20.04, 22.04, 24.04"
            fi
            ;;
        rocky|rhel|centos)
            if [[ ! "$VERSION" =~ ^[89]$ ]]; then
                warn "Unsupported RHEL/Rocky/CentOS version: $VERSION. Supported: 8, 9"
            fi
            ;;
        fedora)
            if [[ "$VERSION" -lt 38 ]]; then
                warn "Unsupported Fedora version: $VERSION. Supported: 38+"
            fi
            ;;
        *)
            warn "Unsupported operating system: $OS"
            ;;
    esac

    # Check system requirements
    local mem_gb=$(($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024))
    local cpu_cores=$(nproc)
    local disk_space_gb=$(($(df / | tail -1 | awk '{print $4}') / 1024 / 1024))

    log "System Information:"
    log "  OS: $OS $VERSION"
    log "  Memory: ${mem_gb} GB"
    log "  CPU Cores: $cpu_cores"
    log "  Available Disk Space: ${disk_space_gb} GB"

    if [[ $mem_gb -lt 4 ]]; then
        warn "Minimum 4GB RAM recommended, found ${mem_gb}GB"
    fi

    if [[ $cpu_cores -lt 2 ]]; then
        warn "Minimum 2 CPU cores recommended, found $cpu_cores"
    fi

    if [[ $disk_space_gb -lt 20 ]]; then
        warn "Minimum 20GB disk space recommended, found ${disk_space_gb}GB"
    fi
}

install_dependencies() {
    log "Installing dependencies..."

    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y \
                curl \
                wget \
                gnupg \
                ca-certificates \
                software-properties-common \
                apt-transport-https \
                lsb-release
            ;;
        rocky|rhel|centos)
            dnf update -y
            dnf install -y \
                curl \
                wget \
                gnupg2 \
                ca-certificates \
                dnf-plugins-core
            ;;
        fedora)
            dnf update -y
            dnf install -y \
                curl \
                wget \
                gnupg2 \
                ca-certificates
            ;;
    esac
}

install_docker() {
    log "Installing Docker..."

    case $OS in
        ubuntu|debian)
            # Add Docker's official GPG key
            curl -fsSL https://download.docker.com/linux/${OS}/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

            # Add Docker repository
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${OS} $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        rocky|rhel|centos)
            # Add Docker repository
            dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

            # Install Docker
            dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        fedora)
            # Install Docker
            dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
    esac

    # Start and enable Docker
    systemctl start docker
    systemctl enable docker

    # Test Docker installation
    if ! docker --version > /dev/null 2>&1; then
        error "Docker installation failed"
    fi

    log "Docker installed successfully"
}

create_user() {
    log "Creating AD-Stack user..."

    if ! getent group $GROUP > /dev/null 2>&1; then
        groupadd $GROUP
    fi

    if ! getent passwd $USER > /dev/null 2>&1; then
        useradd -r -s /bin/false -g $GROUP -d $INSTALL_DIR $USER
    fi

    # Add user to docker group
    usermod -aG docker $USER

    log "AD-Stack user created successfully"
}

create_directories() {
    log "Creating directories..."

    mkdir -p $INSTALL_DIR $CONFIG_DIR $DATA_DIR $LOG_DIR
    mkdir -p $DATA_DIR/{postgresql,redis,samba}

    chown -R $USER:$GROUP $INSTALL_DIR $CONFIG_DIR $DATA_DIR $LOG_DIR

    log "Directories created successfully"
}

configure_firewall() {
    log "Configuring firewall..."

    if command -v ufw > /dev/null; then
        # Ubuntu/Debian with ufw
        ufw --force enable
        ufw allow 53/tcp
        ufw allow 53/udp
        ufw allow 88/tcp
        ufw allow 88/udp
        ufw allow 389/tcp
        ufw allow 636/tcp
        ufw allow 443/tcp
        ufw allow 464/tcp
        ufw allow 464/udp
        ufw allow 8080/tcp
        ufw allow 9090/tcp
        ufw reload
    elif command -v firewall-cmd > /dev/null; then
        # RHEL/CentOS/Fedora with firewalld
        systemctl start firewalld
        systemctl enable firewalld
        firewall-cmd --permanent --add-port=53/tcp
        firewall-cmd --permanent --add-port=53/udp
        firewall-cmd --permanent --add-port=88/tcp
        firewall-cmd --permanent --add-port=88/udp
        firewall-cmd --permanent --add-port=389/tcp
        firewall-cmd --permanent --add-port=636/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --permanent --add-port=464/tcp
        firewall-cmd --permanent --add-port=464/udp
        firewall-cmd --permanent --add-port=8080/tcp
        firewall-cmd --permanent --add-port=9090/tcp
        firewall-cmd --reload
    else
        warn "No supported firewall found. Please configure manually."
    fi

    log "Firewall configured successfully"
}

download_adstack() {
    log "Downloading AD-Stack..."

    cd $INSTALL_DIR

    # Download docker-compose file
    curl -fsSL https://raw.githubusercontent.com/fahertym/AD-Stack/main/docker/production/docker-compose.yml -o docker-compose.yml

    # Download environment template
    curl -fsSL https://raw.githubusercontent.com/fahertym/AD-Stack/main/docker/production/.env.example -o .env

    chown $USER:$GROUP docker-compose.yml .env

    log "AD-Stack downloaded successfully"
}

generate_passwords() {
    log "Generating secure passwords..."

    POSTGRES_PASSWORD=$(openssl rand -base64 32)
    REDIS_PASSWORD=$(openssl rand -base64 32)
    JWT_SECRET=$(openssl rand -base64 64)
    ENCRYPTION_KEY=$(openssl rand -base64 32)

    log "Passwords generated successfully"
}

create_config() {
    log "Creating configuration..."

    # Update environment file
    cat > $INSTALL_DIR/.env << EOF
# Domain Configuration
AD_DOMAIN=$DOMAIN
AD_REALM=$REALM
AD_ADMIN_PASSWORD=$ADMIN_PASSWORD

# Network Configuration  
AD_SERVER_IP=$SERVER_IP
AD_DNS_FORWARDERS=8.8.8.8,8.8.4.4

# Database Configuration
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
REDIS_PASSWORD=$REDIS_PASSWORD

# Security Configuration
JWT_SECRET=$JWT_SECRET
ENCRYPTION_KEY=$ENCRYPTION_KEY

# Application Configuration
AD_STACK_VERSION=latest
COMPOSE_PROJECT_NAME=ad-stack
EOF

    chown $USER:$GROUP $INSTALL_DIR/.env
    chmod 600 $INSTALL_DIR/.env

    log "Configuration created successfully"
}

create_systemd_service() {
    log "Creating systemd service..."

    cat > /etc/systemd/system/ad-stack.service << EOF
[Unit]
Description=AD-Stack Active Directory Replacement
Documentation=https://docs.ad-stack.org
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=$USER
Group=$GROUP
WorkingDirectory=$INSTALL_DIR
Environment=COMPOSE_PROJECT_NAME=ad-stack
ExecStart=/usr/bin/docker compose -f $INSTALL_DIR/docker-compose.yml up -d
ExecStop=/usr/bin/docker compose -f $INSTALL_DIR/docker-compose.yml down
ExecReload=/usr/bin/docker compose -f $INSTALL_DIR/docker-compose.yml restart
TimeoutStartSec=300
TimeoutStopSec=120

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectHome=yes
ProtectSystem=strict
ReadWritePaths=$INSTALL_DIR $DATA_DIR $LOG_DIR

# Restart policy
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ad-stack

    log "Systemd service created successfully"
}

start_services() {
    log "Starting AD-Stack services..."

    systemctl start ad-stack

    # Wait for services to be ready
    log "Waiting for services to start..."
    sleep 30

    # Check health
    for i in {1..30}; do
        if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
            log "AD-Stack is ready!"
            break
        fi
        sleep 10
        if [[ $i -eq 30 ]]; then
            error "AD-Stack failed to start. Check logs: journalctl -u ad-stack"
        fi
    done

    log "Services started successfully"
}

prompt_for_config() {
    if [[ "$SKIP_PROMPTS" == "true" ]]; then
        return
    fi

    echo -e "${BLUE}AD-Stack Installation Configuration${NC}"
    echo

    # Domain configuration
    read -p "Enter domain name (e.g., company.local): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        error "Domain name is required"
    fi

    REALM=$(echo "$DOMAIN" | tr '[:lower:]' '[:upper:]')
    read -p "Enter realm name [$REALM]: " realm_input
    if [[ -n "$realm_input" ]]; then
        REALM="$realm_input"
    fi

    # Admin password
    while [[ -z "$ADMIN_PASSWORD" ]]; do
        read -s -p "Enter administrator password (min 8 characters): " ADMIN_PASSWORD
        echo
        if [[ ${#ADMIN_PASSWORD} -lt 8 ]]; then
            error "Password must be at least 8 characters"
        fi
    done

    # Server IP
    default_ip=$(ip route get 1 | awk '{print $7; exit}')
    read -p "Enter server IP address [$default_ip]: " SERVER_IP
    if [[ -z "$SERVER_IP" ]]; then
        SERVER_IP="$default_ip"
    fi

    # Monitoring
    read -p "Enable monitoring (Prometheus/Grafana)? [y/N]: " monitoring
    if [[ "$monitoring" =~ ^[Yy]$ ]]; then
        ENABLE_MONITORING=true
    fi

    echo
    log "Configuration summary:"
    log "  Domain: $DOMAIN"
    log "  Realm: $REALM"
    log "  Server IP: $SERVER_IP"
    log "  Monitoring: $ENABLE_MONITORING"
    echo

    read -p "Continue with installation? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        error "Installation cancelled"
    fi
}

show_completion_info() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   AD-Stack Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}Access Information:${NC}"
    echo -e "  Web Console: ${GREEN}https://$SERVER_IP:9090${NC}"
    echo -e "  API Endpoint: ${GREEN}https://$SERVER_IP:8080/api/v1${NC}"
    echo -e "  Domain: ${GREEN}$DOMAIN${NC}"
    echo -e "  Administrator: ${GREEN}administrator${NC}"
    echo
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Access the web console and complete domain setup"
    echo "2. Configure DNS on your network to point to $SERVER_IP"
    echo "3. Join Windows/Linux clients to the domain"
    echo "4. Create users and groups as needed"
    echo
    echo -e "${BLUE}Useful Commands:${NC}"
    echo "  Check status: ${GREEN}systemctl status ad-stack${NC}"
    echo "  View logs: ${GREEN}journalctl -u ad-stack -f${NC}"
    echo "  Restart services: ${GREEN}systemctl restart ad-stack${NC}"
    echo
    echo -e "${BLUE}Documentation:${NC}"
    echo "  Installation Guide: https://docs.ad-stack.org/installation"
    echo "  User Guide: https://docs.ad-stack.org/user-guide"
    echo "  Troubleshooting: https://docs.ad-stack.org/troubleshooting"
    echo
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -d, --domain DOMAIN         Domain name (e.g., company.local)"
    echo "  -r, --realm REALM           Realm name (default: uppercase domain)"
    echo "  -p, --password PASSWORD     Administrator password"
    echo "  -i, --ip IP                 Server IP address"
    echo "  -m, --monitoring            Enable monitoring stack"
    echo "  -y, --yes                   Skip prompts and use defaults"
    echo "  -h, --help                  Show this help message"
    echo
    echo "Example:"
    echo "  $0 -d company.local -p 'SecurePass123!' -i 192.168.1.100 -m"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -r|--realm)
            REALM="$2"
            shift 2
            ;;
        -p|--password)
            ADMIN_PASSWORD="$2"
            shift 2
            ;;
        -i|--ip)
            SERVER_IP="$2"
            shift 2
            ;;
        -m|--monitoring)
            ENABLE_MONITORING=true
            shift
            ;;
        -y|--yes)
            SKIP_PROMPTS=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Main installation flow
main() {
    echo -e "${BLUE}AD-Stack Installation Script${NC}"
    echo -e "${BLUE}============================${NC}"
    echo

    check_root
    check_system
    prompt_for_config
    
    install_dependencies
    install_docker
    create_user
    create_directories
    configure_firewall
    download_adstack
    generate_passwords
    create_config
    create_systemd_service
    start_services
    
    show_completion_info
}

# Run main function
main "$@"