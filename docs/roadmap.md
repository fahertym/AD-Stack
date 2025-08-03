# AD-Stack Roadmap

## Vision Statement

AD-Stack aims to be the definitive open-source Active Directory replacement for Small to Medium Businesses (SMBs), providing enterprise-grade identity management with SMB-focused simplicity and cost-effectiveness.

## Project Status

**Current Phase**: Phase 0 - Foundation
**Target Release**: Q3 2025 for Phase 1

| Component | Status | Progress |
|-----------|--------|----------|
| Project Scaffolding | ✅ Complete | 100% |
| Core Architecture | ✅ Complete | 100% |
| Rust Backend | 🚧 In Progress | 30% |
| Web UI Framework | 🚧 In Progress | 20% |
| Container Setup | 🚧 In Progress | 40% |
| Documentation | 🚧 In Progress | 60% |

## Release Timeline

### Phase 0: Foundation (Q1-Q2 2025) ✅
**Goal**: Establish project foundation and development infrastructure

#### Completed ✅
- [x] Project structure and scaffolding
- [x] CI/CD pipeline setup
- [x] Core Rust workspace architecture
- [x] Docker containerization framework
- [x] Documentation structure
- [x] Community guidelines and templates

#### In Progress 🚧
- [ ] Basic web UI framework (React + PatternFly)
- [ ] Core API endpoints (users, groups, health)
- [ ] Container orchestration setup
- [ ] Installation automation scripts

#### Planned for Phase 0 📋
- [ ] Minimal Samba 4 integration
- [ ] Basic user/group CRUD operations
- [ ] Docker Compose development environment
- [ ] Initial documentation and tutorials

**Success Criteria**:
- ✅ All core components compile and build
- ✅ CI/CD passes all tests
- ✅ Docker containers start without errors
- 🚧 Basic CRUD operations work via API
- 🚧 Web UI displays and allows basic navigation

---

### Phase 1: Identity Core (Q3-Q4 2025)
**Goal**: Basic Active Directory functionality for small offices

#### Identity Management
- [ ] **Samba 4 AD DC Integration**
  - Domain controller setup and configuration
  - LDAP/Kerberos authentication
  - Windows client compatibility
  - Linux client enrollment (SSSD + realmd)

- [ ] **User Management**
  - Web-based user creation, modification, deletion
  - Password policy enforcement
  - Account lockout/unlock functionality
  - User profile management
  - Bulk user import/export (CSV)

- [ ] **Group Management**
  - Security and distribution groups
  - Nested group support
  - Group membership management
  - Organizational Units (OU) structure

#### DNS Integration
- [ ] **DNS Service Setup**
  - PowerDNS or Bind9 integration
  - SRV record automation for AD services
  - Forward and reverse DNS zones
  - Dynamic DNS updates

#### Web Console
- [ ] **Administrative Interface**
  - Dashboard with system overview
  - User/group management forms
  - Domain status monitoring
  - Basic reporting capabilities
  - Mobile-responsive design

#### Client Integration
- [ ] **Windows Client Support**
  - Domain join automation
  - Group Policy basics (registry settings)
  - Roaming profiles setup
  - Network drive mapping

- [ ] **Linux Client Support**
  - Automated SSSD configuration
  - SSH key management
  - Sudo rule integration
  - Home directory automation

#### Deployment
- [ ] **Installation Automation**
  - One-command installer script
  - Ansible playbook for deployment
  - Configuration wizard
  - Backup/restore procedures

**Success Criteria**:
- Windows 10/11 clients can join the domain
- Linux clients can authenticate via SSSD
- Web console allows full user/group management
- DNS resolution works for domain services
- Installation completes in under 30 minutes

**Target SMB Size**: 5-25 users

---

### Phase 2: Policy & Access (Q1-Q2 2026)
**Goal**: Group Policy management and file sharing

#### Group Policy Management
- [ ] **Policy Editor**
  - Visual policy editor in web console
  - Top 10 SMB-relevant policies implemented
  - Policy templates for common scenarios
  - Policy testing and rollback capabilities

- [ ] **Windows Integration**
  - Registry-based policy application
  - Software installation policies
  - Desktop and security policies
  - Printer management policies

- [ ] **Linux Policy Sync**
  - Ansible-based policy application
  - Configuration management integration
  - Package management policies
  - Security policy enforcement

#### File Sharing
- [ ] **File Share Management**
  - Web-based share creation wizard
  - ACL management interface
  - Quota management
  - Backup integration

- [ ] **Multi-Protocol Support**
  - CIFS/SMB file sharing
  - NFS for Linux clients
  - SFTP/WebDAV access
  - Mobile file access

#### Enhanced Security
- [ ] **Access Control**
  - Fine-grained permissions
  - Audit logging for all access
  - Security event monitoring
  - Automated threat detection

#### Print Services
- [ ] **Print Server Integration**
  - CUPS integration for Linux
  - Windows print server setup
  - Driver management
  - Print queue monitoring

**Success Criteria**:
- Group policies apply to Windows and Linux clients
- File shares accessible from all client types
- Print services work seamlessly
- Audit logs capture all security events

**Target SMB Size**: 25-75 users

---

### Phase 3: Security Services (Q3-Q4 2026)
**Goal**: Enterprise-grade security and compliance

#### Certificate Authority
- [ ] **PKI Infrastructure**
  - Dogtag PKI integration
  - Certificate lifecycle management
  - Auto-enrollment for domain computers
  - Certificate revocation handling

- [ ] **SSL/TLS Management**
  - Web server certificate automation
  - Client certificate authentication
  - Certificate monitoring and renewal
  - LDAP certificate publishing

#### Multi-Factor Authentication
- [ ] **MFA Implementation**
  - TOTP (Google Authenticator) support
  - SMS-based authentication
  - Hardware token support (FIDO2/WebAuthn)
  - Backup authentication methods

#### RADIUS Integration
- [ ] **Network Authentication**
  - FreeRADIUS integration
  - 802.1X wireless authentication
  - VPN authentication
  - Network device authentication

#### Single Sign-On
- [ ] **SSO Bridge**
  - Keycloak integration
  - SAML identity provider
  - OAuth 2.0/OpenID Connect
  - Application integration wizard

#### Advanced Security
- [ ] **Threat Detection**
  - Failed login monitoring
  - Unusual activity detection
  - Automated account lockouts
  - Security event correlation

**Success Criteria**:
- PKI certificates automatically deployed
- MFA enforced for administrative access
- RADIUS authentication for wireless/VPN
- SSO integration with common business applications

**Target SMB Size**: 50-150 users

---

### Phase 4: Operations & Scale (Q1-Q2 2027)
**Goal**: Production-ready operations and larger SMB support

#### Backup & Recovery
- [ ] **Data Protection**
  - Automated backup scheduling
  - Point-in-time recovery
  - Disaster recovery procedures
  - Cross-site replication

#### Monitoring & Alerting
- [ ] **Observability**
  - Prometheus metrics collection
  - Grafana dashboard templates
  - AlertManager integration
  - Health check automation

- [ ] **Performance Monitoring**
  - Real-time performance metrics
  - Capacity planning tools
  - Bottleneck identification
  - Optimization recommendations

#### High Availability
- [ ] **Clustering Support**
  - Active-passive failover
  - Database replication
  - Load balancing
  - Shared storage integration

#### Update Management
- [ ] **Maintenance Automation**
  - Rolling update procedures
  - Security patch management
  - Configuration drift detection
  - Automated testing pipelines

#### Remote Access
- [ ] **Remote Desktop Services**
  - Apache Guacamole integration
  - VPN server setup
  - Remote administration tools
  - Mobile device support

#### Advanced Integrations
- [ ] **Cloud Connectors**
  - Azure AD synchronization
  - Google Workspace integration
  - Office 365 SSO
  - Cloud backup services

**Success Criteria**:
- 99.9% uptime SLA achievable
- Automated recovery from common failures
- Remote access for distributed teams
- Cloud integration for hybrid environments

**Target SMB Size**: 100-500 users

---

## Success Metrics

### Technical Metrics
- **Installation Time**: < 30 minutes from zero to operational
- **Client Join Time**: < 5 minutes for Windows/Linux domain join
- **Authentication Latency**: < 100ms average response time
- **Uptime**: 99.9% availability target
- **Scalability**: Support for 500+ concurrent users

### User Experience Metrics
- **Setup Difficulty**: Non-technical users can complete basic setup
- **Management Ease**: Common tasks completable without documentation
- **Support Burden**: < 2 hours/month administrative overhead
- **Learning Curve**: < 1 day for basic proficiency

### Business Metrics
- **Cost Savings**: 70%+ reduction vs. Windows Server licensing
- **Time to Value**: Operational within 1 business day
- **ROI**: Positive return within 6 months
- **Market Adoption**: 1000+ production deployments by end of Phase 4

## Community Development

### Contributor Growth
- **Phase 1**: 10+ regular contributors
- **Phase 2**: 25+ regular contributors  
- **Phase 3**: 50+ regular contributors
- **Phase 4**: 100+ regular contributors

### Documentation Goals
- **User Documentation**: Complete tutorials for all major workflows
- **Developer Documentation**: API documentation and contribution guides
- **Deployment Guides**: Platform-specific installation instructions
- **Troubleshooting**: Common issues and resolution procedures

### Certification Program
- **Phase 3**: Launch AD-Stack administrator certification
- **Phase 4**: Partner certification program for MSPs
- **Phase 4**: Integration certification for software vendors

## Risk Mitigation

### Technical Risks
- **Samba Compatibility**: Maintain compatibility with Samba AD DC updates
- **Windows Changes**: Adapt to Microsoft protocol changes
- **Performance Scaling**: Ensure architecture scales to target user counts
- **Security Vulnerabilities**: Rapid response to security issues

### Market Risks
- **Competition**: Microsoft pricing changes or feature additions
- **Adoption**: SMB market acceptance of open-source solutions
- **Support**: Availability of qualified technical support
- **Integration**: Third-party application compatibility

### Mitigation Strategies
- **Modular Architecture**: Reduce vendor lock-in and increase flexibility
- **Strong Testing**: Comprehensive test suite for compatibility assurance  
- **Community Building**: Diverse contributor base and governance model
- **Commercial Support**: Partner ecosystem for professional services

## Long-term Vision (2027+)

### Market Position
- Recognized as the leading open-source AD alternative
- Default choice for SMB identity management
- Strong ecosystem of integrations and partners
- Stable, enterprise-grade platform

### Technology Evolution
- **AI Integration**: Intelligent threat detection and optimization
- **Edge Computing**: Branch office and remote work optimization
- **Zero Trust**: Built-in zero trust architecture
- **Cloud Native**: Full Kubernetes operator model

### Community Sustainability
- **Foundation Governance**: Transition to foundation governance model
- **Sustainable Funding**: Diversified funding from users and sponsors
- **Global Community**: Contributors and users worldwide
- **Ecosystem Partners**: ISVs, MSPs, and cloud providers

This roadmap is a living document that will be updated based on community feedback, market conditions, and technical discoveries. Our commitment is to maintain SMB focus while building enterprise-grade capabilities.