# AD-Stack

> **A turnkey, GUI-driven, open-source replacement for Windows Active Directory—built for SMBs, powered by Samba, FreeIPA, Dogtag PKI, Keycloak and Cockpit.**

[![CI](https://github.com/fahertym/AD-Stack/workflows/CI/badge.svg)](https://github.com/fahertym/AD-Stack/actions)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/discord/YOUR_DISCORD_ID?label=Community&logo=discord)](https://discord.gg/YOUR_INVITE)

| Status | Minimum Viable Deliverable |
|--------|---------------------------|
| 🚧 Pre-alpha | One-node Domain Controller with GUI-based user & group CRUD |

## 🎯 Vision

AD-Stack eliminates the complexity barrier that prevents SMBs from adopting open-source infrastructure. No more choosing between expensive Windows licensing or spending weeks configuring disparate Linux tools.

**One installer. One web console. One login. Full Active Directory replacement.**

## ✨ Value Proposition

- **🎛️ Unified Management** – Single web UI for users, groups, DNS, certificates, policies, and file shares
- **🐧 Linux-First, Windows-Friendly** – Native Linux support with seamless Windows client integration
- **☁️ Cloud-Agnostic** – Deploy on-premises, cloud, or hybrid environments
- **⚡ 10-Minute Setup** – `ansible-playbook ad-stack.yml` and you're enrolling clients
- **🔒 Enterprise Security** – Kerberos, PKI, MFA, and audit logging out of the box
- **💰 Zero Licensing Costs** – AGPL-licensed, community-driven

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│          Web Management Console         │
│        (Cockpit + React + PatternFly)   │
├─────────────────────────────────────────┤
│          Orchestration Layer            │
│     (Rust operators + REST APIs)        │
├─────────────────────────────────────────┤
│            Core Services                │
│  ┌─────────┬──────────┬─────────────────┤
│  │ Samba 4 │ Dogtag   │ FreeRADIUS      │
│  │ AD DC   │ PKI      │ + Keycloak      │
│  └─────────┴──────────┴─────────────────┤
├─────────────────────────────────────────┤
│         Data & State Store              │
│    (PostgreSQL + LDAP + File Storage)   │
└─────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Rocky Linux 9+ / Ubuntu 22.04+ / Fedora 38+
- 4GB RAM, 2 CPU cores, 20GB storage
- Static IP address recommended

### Installation
```bash
# Clone the repository
git clone https://github.com/fahertym/AD-Stack.git
cd AD-Stack

# Run the installer
sudo ./scripts/install.sh

# Access the web console
firefox https://your-server-ip:9090
```

### Development Setup
```bash
# Start development environment
docker compose -f docker/dev/docker-compose.yml up -d

# Install UI dependencies
cd ui && npm install && npm start

# Visit development console
open https://localhost:3000
```

## 📋 Current Features (Phase 0)

- [x] 🏗️ Project scaffolding and CI/CD
- [ ] 🔧 Samba 4 AD DC deployment automation
- [ ] 👥 Web-based user and group management
- [ ] 🌐 Integrated DNS management
- [ ] 🐧 Linux client auto-enrollment
- [ ] 📁 File share creation wizard

## 🗺️ Roadmap

### Phase 1: Identity Core (Q3 2025)
- Domain Controller with Samba 4.22+
- User/Group/OU management via web UI
- DNS integration with SRV record automation
- Linux client enrollment (SSSD + realmd)
- Basic audit logging

### Phase 2: Policy & Access (Q4 2025)
- Visual Group Policy editor for top 10 SMB policies
- File share wizard with ACL management
- Linux policy synchronization via Ansible
- Print server integration (CUPS)

### Phase 3: Security Services (Q1 2026)
- Certificate Authority (Dogtag PKI)
- 802.1X/RADIUS authentication (FreeRADIUS)
- Multi-factor authentication
- Single Sign-On bridge (Keycloak)

### Phase 4: Operations (Q2 2026)
- Backup and disaster recovery
- Monitoring dashboards (Prometheus + Grafana)
- Update management
- Remote desktop gateway (Guacamole)

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Focus Areas
- **Backend**: Rust (orchestration), Python (Ansible), Shell (automation)
- **Frontend**: React + TypeScript + PatternFly (Cockpit plugin)
- **Infrastructure**: Containers, Ansible, systemd
- **Integration**: Samba, FreeIPA, Dogtag, Keycloak APIs

## 📜 License

AGPL-3.0 – see [LICENSE](LICENSE). This ensures improvements stay in the commons and benefit the entire SMB community.

## 🙏 Acknowledgments

Built on the shoulders of giants:
- [Samba](https://samba.org) - SMB/CIFS and AD DC implementation
- [Cockpit](https://cockpit-project.org) - Web-based server administration
- [PatternFly](https://patternfly.org) - Enterprise UI component library
- [FreeIPA](https://freeipa.org) - Identity management inspiration
- [Dogtag PKI](https://dogtag-pki.org) - Certificate authority

## 🆘 Support

- 📖 [Documentation](docs/)
- 💬 [GitHub Discussions](https://github.com/fahertym/AD-Stack/discussions)
- 🐛 [Issue Tracker](https://github.com/fahertym/AD-Stack/issues)
- 💬 [Community Discord](https://discord.gg/YOUR_INVITE)

---

**AD-Stack**: *Democratizing enterprise identity management for the open-source era.*
