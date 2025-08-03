# ADR-0001: Technology Stack Selection

## Status

Accepted

## Context

AD-Stack needs a robust, performant, and maintainable technology stack that supports:

1. **SMB Focus**: Easy deployment and management for small technical teams
2. **Performance**: Handle 500+ concurrent users with low latency
3. **Security**: Enterprise-grade security for identity management
4. **Maintainability**: Modern tooling and active community support
5. **Integration**: Seamless integration with existing SMB infrastructure
6. **Cost**: No licensing costs, minimal infrastructure requirements

The technology choices affect development velocity, operational complexity, security posture, and long-term maintainability.

## Decision

### Backend: Rust
- **Core Services**: Rust with Tokio async runtime
- **Web Framework**: Axum for REST APIs
- **Database**: PostgreSQL with SQLx
- **Caching**: Redis for session and DNS caching
- **Message Queue**: NATS for service communication

### Frontend: React + TypeScript + PatternFly
- **Framework**: React 18+ with TypeScript
- **UI Library**: PatternFly 5 for enterprise design system
- **Build Tool**: Vite for fast development and building
- **State Management**: React Query + Context API
- **Testing**: Jest + React Testing Library

### Infrastructure: Docker + Ansible
- **Containerization**: Docker for all services
- **Orchestration**: Docker Compose (dev), Kubernetes (production)
- **Deployment**: Ansible playbooks for automation
- **Monitoring**: Prometheus + Grafana
- **Reverse Proxy**: Nginx or Traefik

### Core Services Integration
- **Active Directory**: Samba 4 AD DC
- **DNS**: PowerDNS with API integration
- **PKI**: Dogtag PKI for certificate management
- **File Sharing**: Samba for CIFS/SMB, NFS for Linux

## Consequences

### Positive

1. **Performance**: Rust provides memory safety and high performance
2. **Type Safety**: TypeScript and Rust prevent many runtime errors
3. **Modern Tooling**: Excellent development experience and ecosystem
4. **Security**: Memory-safe languages and mature security libraries
5. **Container-Native**: Easy deployment and scaling
6. **Enterprise UI**: PatternFly provides proven enterprise patterns
7. **Open Source**: No licensing costs or vendor lock-in
8. **Active Communities**: Strong community support and regular updates

### Negative

1. **Learning Curve**: Rust has a steeper learning curve than some alternatives
2. **Compile Times**: Rust compilation can be slower than interpreted languages
3. **Ecosystem Maturity**: Some Rust crates are newer than established alternatives
4. **Complexity**: Multiple technologies increase operational complexity
5. **Resource Usage**: JIT-compiled languages might use more memory initially

### Risks

1. **Rust Expertise**: Limited pool of Rust developers
2. **Integration Complexity**: Multiple services increase integration testing needs
3. **Deployment Complexity**: Container orchestration adds operational overhead
4. **Performance Tuning**: May require significant optimization for large deployments

## Alternatives Considered

### Backend Alternatives

#### Go
**Pros**: Simple language, good performance, large ecosystem
**Cons**: Less memory safety than Rust, garbage collection pauses
**Decision**: Rust chosen for superior memory safety and performance

#### Python (FastAPI/Django)
**Pros**: Large ecosystem, rapid development, many libraries
**Cons**: Performance limitations, GIL constraints, runtime errors
**Decision**: Performance requirements favor compiled languages

#### Java (Spring Boot)
**Pros**: Mature ecosystem, enterprise tooling, large talent pool
**Cons**: Memory usage, complexity, licensing concerns with Oracle
**Decision**: Rust provides better resource efficiency for SMB deployments

#### C# (.NET)
**Pros**: Strong typing, good performance, Microsoft ecosystem
**Cons**: Windows bias, licensing complexity, less Linux-native
**Decision**: Prefer fully open-source stack

### Frontend Alternatives

#### Vue.js
**Pros**: Gentler learning curve, good performance
**Cons**: Smaller ecosystem than React, less enterprise adoption
**Decision**: React has stronger enterprise component libraries

#### Angular
**Pros**: Full framework, TypeScript by default, enterprise features
**Cons**: Heavy framework, complex for simple UIs, steep learning curve
**Decision**: React provides better flexibility and developer experience

#### Svelte
**Pros**: Excellent performance, smaller bundle sizes
**Cons**: Smaller ecosystem, less enterprise tooling
**Decision**: React has better long-term support and community

### Database Alternatives

#### MySQL
**Pros**: Wide adoption, good performance, familiar to many developers
**Cons**: Less advanced features than PostgreSQL, licensing complexity
**Decision**: PostgreSQL provides better JSON support and extensibility

#### MongoDB
**Pros**: Flexible schema, good for rapid development
**Cons**: Consistency challenges, less ACID guarantees
**Decision**: ACID guarantees essential for identity management

#### SQLite
**Pros**: Simple deployment, no server required
**Cons**: Limited concurrency, not suitable for multi-user scenarios
**Decision**: PostgreSQL needed for concurrent access

### Infrastructure Alternatives

#### Kubernetes-First
**Pros**: Cloud-native, excellent scaling, standardized
**Cons**: Operational complexity, resource overhead for small deployments
**Decision**: Docker Compose for small deployments, K8s optional for scale

#### Virtual Machines
**Pros**: Familiar to many administrators, well-understood
**Cons**: Resource overhead, slower deployment, less portable
**Decision**: Containers provide better resource efficiency

#### Serverless
**Pros**: Zero infrastructure management, automatic scaling
**Cons**: Vendor lock-in, cold starts, limited for stateful services
**Decision**: Not suitable for identity services requiring persistent connections

## Implementation Guidelines

### Development Standards
1. Use `rustfmt` and `clippy` for Rust code quality
2. Implement comprehensive error handling with `anyhow` and `thiserror`
3. Write unit tests for all business logic
4. Use structured logging with `tracing`
5. Follow React best practices and hooks patterns
6. Implement proper TypeScript typing throughout

### Security Requirements
1. All inter-service communication over TLS
2. Input validation on all API endpoints
3. SQL injection prevention with parameterized queries
4. Authentication token validation on all protected routes
5. Rate limiting on all public APIs
6. Security headers on all HTTP responses

### Performance Targets
1. API response time < 100ms for 95th percentile
2. Database query time < 50ms for user lookups
3. Frontend initial load < 2 seconds
4. Support 500 concurrent users on modest hardware
5. Memory usage < 2GB for full stack on single node

### Deployment Requirements
1. One-command installation for single-node deployment
2. Zero-downtime updates for production deployments
3. Automated backup and recovery procedures
4. Health checks for all services
5. Prometheus metrics for monitoring
6. Structured logging for troubleshooting

## Review Schedule

This ADR should be reviewed:
- When performance requirements change significantly
- When new major versions of core technologies are released
- If community feedback suggests different approaches
- After 12 months of production experience

## References

- [Rust Performance Benchmarks](https://benchmarksgame-team.pages.debian.net/benchmarksgame/)
- [PatternFly Design System](https://www.patternfly.org/)
- [Samba AD DC Documentation](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)
- [PostgreSQL vs MySQL Performance](https://www.postgresql.org/about/featurematrix/)
- [Container Security Best Practices](https://www.nist.gov/publications/application-container-security-guide)