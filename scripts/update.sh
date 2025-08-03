#!/bin/bash

# AD-Stack Update Script
# This script updates an existing AD-Stack installation

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
BACKUP_DIR="/var/backups/ad-stack"
UPDATE_VERSION="latest"
SKIP_BACKUP=false
FORCE_UPDATE=false

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

check_installation() {
    log "Checking existing installation..."

    if [[ ! -d "$INSTALL_DIR" ]]; then
        error "AD-Stack installation not found at $INSTALL_DIR"
    fi

    if [[ ! -f "$INSTALL_DIR/docker-compose.yml" ]]; then
        error "docker-compose.yml not found. Please reinstall AD-Stack."
    fi

    if ! systemctl is-enabled ad-stack >/dev/null 2>&1; then
        error "AD-Stack service not found or not enabled"
    fi

    # Get current version
    local current_version="unknown"
    if [[ -f "$INSTALL_DIR/.version" ]]; then
        current_version=$(cat "$INSTALL_DIR/.version")
    fi

    log "Current version: $current_version"
    log "Target version: $UPDATE_VERSION"

    if [[ "$current_version" == "$UPDATE_VERSION" && "$FORCE_UPDATE" != "true" ]]; then
        log "Already on target version. Use --force to update anyway."
        exit 0
    fi
}

create_backup() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        log "Skipping backup (--skip-backup specified)"
        return
    fi

    log "Creating backup..."

    local backup_timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$BACKUP_DIR/ad-stack_backup_$backup_timestamp"

    mkdir -p "$backup_path"

    # Backup configuration
    if [[ -d "$CONFIG_DIR" ]]; then
        cp -r "$CONFIG_DIR" "$backup_path/"
        log "Configuration backed up"
    fi

    # Backup docker-compose and env files
    cp "$INSTALL_DIR/docker-compose.yml" "$backup_path/"
    if [[ -f "$INSTALL_DIR/.env" ]]; then
        cp "$INSTALL_DIR/.env" "$backup_path/"
    fi

    # Export database
    log "Backing up database..."
    if docker compose -f "$INSTALL_DIR/docker-compose.yml" exec -T postgres pg_dumpall -U ad-stack > "$backup_path/database_backup.sql" 2>/dev/null; then
        log "Database backed up successfully"
    else
        warn "Database backup failed. Continuing with update."
    fi

    # Create backup manifest
    cat > "$backup_path/manifest.txt" << EOF
AD-Stack Backup
Created: $(date)
Version: $(cat "$INSTALL_DIR/.version" 2>/dev/null || echo "unknown")
Hostname: $(hostname)
EOF

    chown -R $USER:$GROUP "$backup_path"
    log "Backup created at $backup_path"
}

stop_services() {
    log "Stopping AD-Stack services..."

    systemctl stop ad-stack || true

    # Wait for containers to stop
    sleep 10

    # Force stop if needed
    if docker compose -f "$INSTALL_DIR/docker-compose.yml" ps -q | grep -q .; then
        warn "Force stopping containers..."
        docker compose -f "$INSTALL_DIR/docker-compose.yml" down --timeout 30
    fi

    log "Services stopped"
}

update_files() {
    log "Updating AD-Stack files..."

    cd "$INSTALL_DIR"

    # Backup current files
    if [[ -f "docker-compose.yml" ]]; then
        cp "docker-compose.yml" "docker-compose.yml.backup"
    fi

    # Download new docker-compose file
    curl -fsSL "https://raw.githubusercontent.com/fahertym/AD-Stack/main/docker/production/docker-compose.yml" -o docker-compose.yml.new

    # Check if download was successful
    if [[ ! -f "docker-compose.yml.new" ]]; then
        error "Failed to download new docker-compose.yml"
    fi

    # Replace old file
    mv "docker-compose.yml.new" "docker-compose.yml"
    chown $USER:$GROUP "docker-compose.yml"

    # Update version file
    echo "$UPDATE_VERSION" > .version
    chown $USER:$GROUP .version

    log "Files updated successfully"
}

pull_images() {
    log "Pulling new Docker images..."

    cd "$INSTALL_DIR"

    # Set the version in environment
    if [[ -f ".env" ]]; then
        if grep -q "AD_STACK_VERSION=" .env; then
            sed -i "s/AD_STACK_VERSION=.*/AD_STACK_VERSION=$UPDATE_VERSION/" .env
        else
            echo "AD_STACK_VERSION=$UPDATE_VERSION" >> .env
        fi
    fi

    # Pull images
    if ! sudo -u $USER docker compose pull; then
        error "Failed to pull Docker images"
    fi

    log "Images pulled successfully"
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
            error "AD-Stack failed to start after update. Check logs: journalctl -u ad-stack"
        fi
    done

    log "Services started successfully"
}

verify_update() {
    log "Verifying update..."

    # Check service status
    if ! systemctl is-active ad-stack >/dev/null 2>&1; then
        error "AD-Stack service is not running"
    fi

    # Check API health
    local health_response
    if health_response=$(curl -sf http://localhost:8080/health); then
        local api_version=$(echo "$health_response" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['version'])" 2>/dev/null || echo "unknown")
        log "API health check passed. Version: $api_version"
    else
        error "API health check failed"
    fi

    # Check database connectivity
    if docker compose -f "$INSTALL_DIR/docker-compose.yml" exec -T postgres pg_isready -U ad-stack >/dev/null 2>&1; then
        log "Database connectivity verified"
    else
        warn "Database connectivity check failed"
    fi

    log "Update verification completed"
}

cleanup() {
    log "Cleaning up..."

    cd "$INSTALL_DIR"

    # Remove backup files
    rm -f docker-compose.yml.backup

    # Clean up old Docker images
    log "Cleaning up old Docker images..."
    docker image prune -f >/dev/null 2>&1 || true

    log "Cleanup completed"
}

rollback() {
    error_msg="$1"
    
    error "Update failed: $error_msg"
    warn "Attempting rollback..."

    cd "$INSTALL_DIR"

    # Stop current services
    systemctl stop ad-stack || true
    docker compose down --timeout 30 || true

    # Restore files if backup exists
    if [[ -f "docker-compose.yml.backup" ]]; then
        mv "docker-compose.yml.backup" "docker-compose.yml"
        log "Restored docker-compose.yml"
    fi

    # Start services
    systemctl start ad-stack || true

    error "Rollback completed. Please check the system and try the update again."
}

show_completion_info() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}     AD-Stack Update Completed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}Update Summary:${NC}"
    echo -e "  Updated to version: ${GREEN}$UPDATE_VERSION${NC}"
    echo -e "  Installation path: ${GREEN}$INSTALL_DIR${NC}"
    echo -e "  Service status: ${GREEN}$(systemctl is-active ad-stack)${NC}"
    echo
    echo -e "${BLUE}Useful Commands:${NC}"
    echo -e "  Check status: ${GREEN}systemctl status ad-stack${NC}"
    echo -e "  View logs: ${GREEN}journalctl -u ad-stack -f${NC}"
    echo -e "  Restart services: ${GREEN}systemctl restart ad-stack${NC}"
    echo
    echo -e "${BLUE}Health Check:${NC}"
    echo -e "  API: ${GREEN}curl http://localhost:8080/health${NC}"
    echo -e "  Web Console: ${GREEN}https://$(hostname -I | awk '{print $1}'):9090${NC}"
    echo
    if [[ "$SKIP_BACKUP" != "true" ]]; then
        echo -e "${BLUE}Backup Location:${NC}"
        echo -e "  ${GREEN}$BACKUP_DIR${NC}"
        echo
    fi
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -v, --version VERSION   Version to update to (default: latest)"
    echo "  --skip-backup           Skip creating backup before update"
    echo "  --force                 Force update even if already on target version"
    echo "  -h, --help              Show this help message"
    echo
    echo "Examples:"
    echo "  $0                      # Update to latest version"
    echo "  $0 -v v1.2.0            # Update to specific version"
    echo "  $0 --skip-backup        # Update without creating backup"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            UPDATE_VERSION="$2"
            shift 2
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --force)
            FORCE_UPDATE=true
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

# Main update flow
main() {
    echo -e "${BLUE}AD-Stack Update Script${NC}"
    echo -e "${BLUE}======================${NC}"
    echo

    # Set trap for error handling
    trap 'rollback "Unexpected error occurred"' ERR

    check_root
    check_installation
    create_backup
    stop_services
    update_files
    pull_images
    start_services
    verify_update
    cleanup

    # Disable trap after successful completion
    trap - ERR

    show_completion_info
}

# Run main function
main "$@"