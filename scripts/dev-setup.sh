#!/bin/bash

# AD-Stack Development Setup Script
# This script sets up a development environment for AD-Stack

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

check_dependencies() {
    log "Checking dependencies..."

    # Check for required tools
    local missing_tools=()

    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi

    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi

    if ! command -v docker compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi

    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi

    if ! command -v rustc &> /dev/null; then
        missing_tools+=("rust")
    fi

    if ! command -v node &> /dev/null; then
        missing_tools+=("nodejs")
    fi

    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
    fi

    log "All dependencies found"
}

setup_rust_env() {
    log "Setting up Rust environment..."

    cd "$PROJECT_DIR"

    # Check Rust version
    local rust_version=$(rustc --version | cut -d' ' -f2)
    log "Rust version: $rust_version"

    # Install required components
    if ! rustup component list --installed | grep -q clippy; then
        log "Installing clippy..."
        rustup component add clippy
    fi

    if ! rustup component list --installed | grep -q rustfmt; then
        log "Installing rustfmt..."
        rustup component add rustfmt
    fi

    # Install additional targets if needed
    if ! rustup target list --installed | grep -q x86_64-unknown-linux-musl; then
        log "Installing musl target..."
        rustup target add x86_64-unknown-linux-musl
    fi

    log "Rust environment ready"
}

setup_frontend_env() {
    log "Setting up frontend environment..."

    cd "$PROJECT_DIR/ui"

    # Check Node.js version
    local node_version=$(node --version)
    local npm_version=$(npm --version)
    log "Node.js version: $node_version"
    log "npm version: $npm_version"

    # Install dependencies
    log "Installing frontend dependencies..."
    npm install

    cd "$PROJECT_DIR"
    log "Frontend environment ready"
}

create_dev_config() {
    log "Creating development configuration..."

    # Create .env file for development
    if [[ ! -f "$PROJECT_DIR/docker/dev/.env" ]]; then
        cp "$PROJECT_DIR/docker/dev/.env.example" "$PROJECT_DIR/docker/dev/.env"
        log "Created development .env file"
    else
        log "Development .env file already exists"
    fi

    # Create git hooks directory
    mkdir -p "$PROJECT_DIR/.git/hooks"

    # Create pre-commit hook
    cat > "$PROJECT_DIR/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for AD-Stack

set -e

echo "Running pre-commit checks..."

# Check Rust formatting
if ! cargo fmt --check; then
    echo "❌ Rust code is not formatted. Run 'cargo fmt' to fix."
    exit 1
fi

# Run Rust linting
if ! cargo clippy -- -D warnings; then
    echo "❌ Rust linting failed. Fix clippy warnings."
    exit 1
fi

# Check frontend formatting
cd ui
if ! npm run format:check; then
    echo "❌ Frontend code is not formatted. Run 'npm run format' to fix."
    exit 1
fi

# Run frontend linting
if ! npm run lint; then
    echo "❌ Frontend linting failed. Fix ESLint warnings."
    exit 1
fi

echo "✅ All pre-commit checks passed!"
EOF

    chmod +x "$PROJECT_DIR/.git/hooks/pre-commit"
    log "Created pre-commit hook"
}

build_rust_project() {
    log "Building Rust project..."

    cd "$PROJECT_DIR"

    # Build in debug mode
    cargo build

    # Run tests
    log "Running Rust tests..."
    cargo test

    log "Rust project built successfully"
}

build_frontend() {
    log "Building frontend..."

    cd "$PROJECT_DIR/ui"

    # Run linting
    npm run lint

    # Run type checking
    npm run type-check

    # Run tests
    log "Running frontend tests..."
    npm test -- --watchAll=false

    cd "$PROJECT_DIR"
    log "Frontend built successfully"
}

setup_docker_env() {
    log "Setting up Docker development environment..."

    cd "$PROJECT_DIR"

    # Build development images
    log "Building Docker images..."
    docker compose -f docker/dev/docker-compose.yml build

    # Create volumes
    log "Creating Docker volumes..."
    docker compose -f docker/dev/docker-compose.yml create

    log "Docker environment ready"
}

start_dev_services() {
    log "Starting development services..."

    cd "$PROJECT_DIR"

    # Start background services (database, cache)
    docker compose -f docker/dev/docker-compose.yml up -d postgres redis

    # Wait for services to be ready
    log "Waiting for services to start..."
    sleep 10

    # Check if services are running
    if ! docker compose -f docker/dev/docker-compose.yml ps | grep -q "postgres.*Up"; then
        error "PostgreSQL failed to start"
    fi

    if ! docker compose -f docker/dev/docker-compose.yml ps | grep -q "redis.*Up"; then
        error "Redis failed to start"
    fi

    log "Development services started successfully"
}

create_dev_data() {
    log "Creating development data..."

    # TODO: Add database migrations and seed data
    log "Development data creation will be implemented with database migrations"
}

show_dev_info() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   Development Environment Ready!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}Available Commands:${NC}"
    echo -e "  Build Rust: ${GREEN}cargo build${NC}"
    echo -e "  Run tests: ${GREEN}cargo test${NC}"
    echo -e "  Run CLI: ${GREEN}cargo run --bin ad-stack -- --help${NC}"
    echo -e "  Start orchestrator: ${GREEN}cargo run --bin orchestrator${NC}"
    echo
    echo -e "  Build frontend: ${GREEN}cd ui && npm run build${NC}"
    echo -e "  Start frontend dev: ${GREEN}cd ui && npm run dev${NC}"
    echo -e "  Run frontend tests: ${GREEN}cd ui && npm test${NC}"
    echo
    echo -e "${BLUE}Docker Commands:${NC}"
    echo -e "  Start all services: ${GREEN}docker compose -f docker/dev/docker-compose.yml up -d${NC}"
    echo -e "  Stop all services: ${GREEN}docker compose -f docker/dev/docker-compose.yml down${NC}"
    echo -e "  View logs: ${GREEN}docker compose -f docker/dev/docker-compose.yml logs -f${NC}"
    echo -e "  Rebuild images: ${GREEN}docker compose -f docker/dev/docker-compose.yml build${NC}"
    echo
    echo -e "${BLUE}Development URLs:${NC}"
    echo -e "  Frontend: ${GREEN}http://localhost:3000${NC}"
    echo -e "  API: ${GREEN}http://localhost:8080/api/v1${NC}"
    echo -e "  API Health: ${GREEN}http://localhost:8080/health${NC}"
    echo -e "  PostgreSQL: ${GREEN}localhost:5432${NC}"
    echo -e "  Redis: ${GREEN}localhost:6379${NC}"
    echo
    echo -e "${BLUE}IDE Setup:${NC}"
    echo "- Install Rust Analyzer extension for VS Code"
    echo "- Install ES7+ React/Redux/React-Native snippets for VS Code"
    echo "- Configure your editor to use the project's rustfmt and ESLint configs"
    echo
    echo -e "${BLUE}Documentation:${NC}"
    echo "  Development Guide: docs/development.md"
    echo "  Architecture: docs/architecture.md"
    echo "  API Documentation: docs/api/README.md"
    echo
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --skip-build        Skip building the project"
    echo "  --skip-docker       Skip Docker setup"
    echo "  --skip-services     Skip starting development services"
    echo "  -h, --help          Show this help message"
    echo
}

# Parse command line arguments
SKIP_BUILD=false
SKIP_DOCKER=false
SKIP_SERVICES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --skip-services)
            SKIP_SERVICES=true
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

# Main setup flow
main() {
    echo -e "${BLUE}AD-Stack Development Setup${NC}"
    echo -e "${BLUE}==========================${NC}"
    echo

    check_dependencies
    setup_rust_env
    setup_frontend_env
    create_dev_config

    if [[ "$SKIP_BUILD" != "true" ]]; then
        build_rust_project
        build_frontend
    fi

    if [[ "$SKIP_DOCKER" != "true" ]]; then
        setup_docker_env
    fi

    if [[ "$SKIP_SERVICES" != "true" ]]; then
        start_dev_services
        create_dev_data
    fi

    show_dev_info
}

# Run main function
main "$@"