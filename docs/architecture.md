# AD-Stack Architecture

## Overview

AD-Stack is designed as a modular, cloud-native Active Directory replacement specifically tailored for Small to Medium Businesses (SMBs). The architecture prioritizes simplicity, reliability, and ease of management while providing enterprise-grade features.

## Design Principles

### 1. SMB-First Design
- **Simplicity**: One-command installation and web-based management
- **Cost-Effective**: No licensing costs, minimal hardware requirements
- **Reliability**: Self-healing and fault-tolerant by design
- **Scalability**: Grows with your business (5-500 users)

### 2. Cloud-Native Architecture
- **Containerized**: All services run in containers for consistency
- **Orchestrated**: Kubernetes-ready for larger deployments
- **Stateless**: Application logic separated from data storage
- **Observable**: Built-in monitoring and logging

### 3. Open Standards
- **LDAP/Kerberos**: Standard authentication protocols
- **SAML/OAuth**: Modern SSO capabilities
- **REST APIs**: Integration-friendly interfaces
- **SQL**: Standard database for configuration and state

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AD-Stack Architecture                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Web Console   │  │   Mobile App    │  │  CLI Tools   │ │
│  │ (React/PatternFly)│  │   (Optional)    │  │  (Rust)      │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                |                             │
├────────────────────────────────┼─────────────────────────────┤
│                                │                             │
│  ┌─────────────────────────────┼─────────────────────────┐   │
│  │             API Gateway / Load Balancer              │   │
│  │                 (Nginx/Traefik)                     │   │
│  └─────────────────────────────┼─────────────────────────┘   │
│                                │                             │
├────────────────────────────────┼─────────────────────────────┤
│                                │                             │
│  ┌─────────────────────────────┼─────────────────────────┐   │
│  │                 Orchestrator Service                │   │
│  │              (Rust - Central Coordinator)           │   │
│  │                                                     │   │
│  │  • Service Discovery & Health Monitoring            │   │
│  │  • Configuration Management                         │   │
│  │  • API Routing & Rate Limiting                      │   │
│  │  • Event Coordination                               │   │
│  └─────────────────────────────┼─────────────────────────┘   │
│                                │                             │
├────────────────────────────────┼─────────────────────────────┤
│                                │                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────┐ │
│  │   Identity  │  │     DNS     │  │     PKI     │  │  File  │ │
│  │   Service   │  │   Service   │  │   Service   │  │ Share  │ │
│  │             │  │             │  │             │  │ Service│ │
│  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌────┐ │ │
│  │ │ Samba 4 │ │  │ │ PowerDNS│ │  │ │ Dogtag  │ │  │ │SFTP│ │ │
│  │ │ AD DC   │ │  │ │   or    │ │  │ │   PKI   │ │  │ │CIFS│ │ │
│  │ └─────────┘ │  │ │ Bind9   │ │  │ └─────────┘ │  │ │NFS │ │ │
│  │             │  │ └─────────┘ │  │             │  │ └────┘ │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────┘ │
│                                                                │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Database    │  │    Cache     │  │    Message Queue     │  │
│  │              │  │              │  │                      │  │
│  │ PostgreSQL   │  │   Redis      │  │   RabbitMQ/NATS      │  │
│  │              │  │              │  │                      │  │
│  │ • Users      │  │ • Sessions   │  │ • Event Bus          │  │
│  │ • Groups     │  │ • Policies   │  │ • Async Tasks        │  │
│  │ • Policies   │  │ • DNS Cache  │  │ • Service Comm       │  │
│  │ • Audit Log  │  │              │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Orchestrator Service (Rust)
**Purpose**: Central coordination and service management

**Responsibilities**:
- Service discovery and health monitoring
- Configuration management and distribution
- API gateway functionality
- Event coordination between services
- Resource allocation and scaling decisions

**Technology**: Rust with Tokio for async operations

### 2. Identity Service
**Purpose**: User and group authentication/authorization

**Core Components**:
- **Samba 4 AD DC**: LDAP/Kerberos authentication
- **User Management**: CRUD operations for users/groups
- **Policy Engine**: Group policies and permissions
- **SSO Integration**: SAML/OAuth providers

**Protocols**: LDAP, Kerberos, SAML, OAuth 2.0

### 3. DNS Service
**Purpose**: Network name resolution and service discovery

**Features**:
- Automatic AD record management
- Dynamic DNS updates
- Service discovery (SRV records)
- Conditional forwarding

**Implementation**: PowerDNS or Bind9 with API integration

### 4. PKI Service
**Purpose**: Certificate management and encryption

**Features**:
- Certificate Authority (CA) management
- Auto-enrollment for domain computers
- Certificate lifecycle management
- LDAP certificate publication

**Implementation**: Dogtag PKI or custom Rust CA

### 5. File Share Service
**Purpose**: Network file storage and sharing

**Protocols**:
- **CIFS/SMB**: Windows compatibility
- **NFS**: Linux/Unix compatibility  
- **SFTP**: Secure file transfer
- **WebDAV**: Web-based access

### 6. Data Layer

#### PostgreSQL Database
- **Users & Groups**: Identity information
- **Policies**: Security and group policies
- **Configuration**: System settings
- **Audit Logs**: Security and access logging

#### Redis Cache
- **Sessions**: User authentication sessions
- **DNS Cache**: Resolved queries
- **Policy Cache**: Compiled policies
- **Rate Limiting**: API throttling data

#### Message Queue
- **Event Bus**: Inter-service communication
- **Async Tasks**: Background job processing
- **Notifications**: Alert and monitoring events

## Network Architecture

### Port Allocation
```
443/tcp  - HTTPS Web Console
80/tcp   - HTTP (redirect to HTTPS)
389/tcp  - LDAP
636/tcp  - LDAPS (LDAP over SSL)
88/tcp   - Kerberos
464/tcp  - Kerberos Password Change
53/tcp   - DNS
53/udp   - DNS
22/tcp   - SSH Management
```

### Security Zones
```
┌─────────────────────────────────────────┐
│              Internet                   │
└─────────────┬───────────────────────────┘
              │
┌─────────────▼───────────────────────────┐
│           DMZ Zone                      │
│  ┌─────────────────┐ ┌─────────────┐    │
│  │  Load Balancer  │ │  Firewall   │    │
│  │  (443, 80)      │ │             │    │
│  └─────────────────┘ └─────────────┘    │
└─────────────┬───────────────────────────┘
              │
┌─────────────▼───────────────────────────┐
│         Management Zone                 │
│  ┌─────────────────────────────────────┐ │
│  │        AD-Stack Services            │ │
│  │  (All internal communication)       │ │
│  └─────────────────────────────────────┘ │
└─────────────┬───────────────────────────┘
              │
┌─────────────▼───────────────────────────┐
│           Client Zone                   │
│  ┌─────────────────┐ ┌─────────────┐    │
│  │  Domain PCs     │ │  Mobile     │    │
│  │  (Windows/Linux)│ │  Devices    │    │
│  └─────────────────┘ └─────────────┘    │
└─────────────────────────────────────────┘
```

## Deployment Models

### 1. Single-Node Deployment (5-25 users)
- All services on one server
- SQLite or PostgreSQL database
- Minimal resource requirements
- Docker Compose orchestration

### 2. Multi-Node Deployment (25-100 users)
- Load balancer + 2-3 application nodes
- Dedicated database server
- Redis cluster for caching
- Container orchestration (Docker Swarm/K3s)

### 3. High-Availability Deployment (100+ users)
- Active-passive or active-active setup
- Database replication
- Shared storage for file services
- Full Kubernetes orchestration

## Data Flow

### User Authentication Flow
```
1. User → Web Console → API Gateway
2. API Gateway → Orchestrator → Identity Service
3. Identity Service → Samba AD DC → LDAP/Kerberos
4. Response propagates back through chain
5. Session stored in Redis cache
```

### DNS Resolution Flow
```
1. Client → DNS Service (port 53)
2. DNS Service → Cache (Redis)
3. If cache miss → Upstream DNS or AD records
4. Response cached and returned to client
```

### File Access Flow
```
1. Client → File Share Service
2. Authentication via Identity Service
3. Authorization via Policy Engine
4. File operation executed
5. Audit log entry created
```

## Monitoring and Observability

### Metrics Collection
- **Prometheus**: Time-series metrics
- **Grafana**: Visualization dashboards
- **AlertManager**: Alert routing and notification

### Logging Strategy
- **Structured Logging**: JSON format for parsing
- **Log Aggregation**: Centralized logging (ELK/EFK stack)
- **Audit Trails**: Security and compliance logging

### Health Monitoring
- **Service Health**: HTTP health checks
- **Database Health**: Connection and query monitoring
- **Resource Monitoring**: CPU, memory, disk usage

## Security Architecture

### Authentication Layers
1. **Web Console**: Session-based authentication
2. **API Access**: JWT tokens or API keys
3. **Service-to-Service**: mTLS certificates
4. **Database Access**: Connection encryption + auth

### Authorization Model
- **Role-Based Access Control (RBAC)**: Simplified role management
- **Attribute-Based Access Control (ABAC)**: Fine-grained permissions
- **Policy Engine**: Centralized policy evaluation

### Data Protection
- **Encryption at Rest**: Database and file encryption
- **Encryption in Transit**: TLS 1.3 for all communication
- **Key Management**: Integrated key rotation
- **Backup Encryption**: Encrypted backup storage

## Performance Considerations

### Scalability Targets
- **Users**: 5-500 concurrent users
- **Requests**: 1000 req/sec peak load
- **Storage**: 10TB+ file storage
- **Latency**: <100ms for authentication

### Optimization Strategies
- **Caching**: Multi-layer caching strategy
- **Connection Pooling**: Database connection management
- **Async Processing**: Non-blocking I/O operations
- **Load Balancing**: Horizontal scaling capability

## Future Architecture Considerations

### Phase 2 Enhancements
- **Multi-Site Replication**: Branch office support
- **Cloud Integration**: Azure AD/Google Workspace sync
- **Advanced Monitoring**: AI-powered anomaly detection
- **Mobile Device Management**: BYOD support

### Emerging Technologies
- **WebAssembly**: Browser-based administrative tools
- **gRPC**: High-performance service communication
- **GraphQL**: Flexible API query language
- **Service Mesh**: Advanced networking and security