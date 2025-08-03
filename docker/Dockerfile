# Multi-stage Dockerfile for AD-Stack

# Build stage for Rust backend
FROM rust:1.75-slim as rust-builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy Cargo files
COPY Cargo.toml Cargo.lock ./
COPY src ./src/
COPY cmd ./cmd/
COPY tests ./tests/

# Build the applications
RUN cargo build --release --bin orchestrator --bin ad-stack

# Frontend build stage
FROM node:18-alpine as frontend-builder

# Set working directory
WORKDIR /app

# Copy package files
COPY ui/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY ui/ ./

# Build the frontend
RUN npm run build

# Runtime stage for orchestrator
FROM debian:bookworm-slim as orchestrator

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd -r adstack && useradd -r -g adstack adstack

# Create app directory
WORKDIR /app

# Copy binary from builder
COPY --from=rust-builder /app/target/release/orchestrator /usr/local/bin/orchestrator

# Create config directory
RUN mkdir -p /etc/ad-stack /var/log/ad-stack && \
    chown -R adstack:adstack /etc/ad-stack /var/log/ad-stack

# Copy default config
COPY docker/config/default-config.yaml /etc/ad-stack/config.yaml

# Switch to app user
USER adstack

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Start the application
CMD ["orchestrator"]

# Runtime stage for CLI
FROM debian:bookworm-slim as cli

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd -r adstack && useradd -r -g adstack adstack

# Copy binary from builder
COPY --from=rust-builder /app/target/release/ad-stack /usr/local/bin/ad-stack

# Switch to app user
USER adstack

# Default command
ENTRYPOINT ["ad-stack"]

# Frontend runtime stage
FROM nginx:alpine as frontend

# Copy built frontend from builder
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Expose port
EXPOSE 80

# All-in-one development image
FROM orchestrator as development

# Install development tools
USER root
RUN apt-get update && apt-get install -y \
    git \
    vim \
    less \
    htop \
    net-tools \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js for frontend development
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Switch back to app user
USER adstack

# Copy source for development
COPY --chown=adstack:adstack . /app/

# Install frontend dependencies
WORKDIR /app/ui
RUN npm install

# Back to app directory
WORKDIR /app

# Development command
CMD ["orchestrator"]