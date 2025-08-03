# AD-Stack Installation Guide

## Overview

AD-Stack provides multiple installation methods to suit different deployment scenarios and technical expertise levels. Choose the method that best fits your environment and requirements.

## System Requirements

### Minimum Requirements (5-25 users)
- **OS**: Ubuntu 22.04 LTS, Rocky Linux 9, or RHEL 9
- **CPU**: 2 cores (x86_64)
- **RAM**: 4 GB
- **Storage**: 20 GB free space
- **Network**: Static IP address recommended

### Recommended Requirements (25-100 users)
- **OS**: Ubuntu 22.04 LTS, Rocky Linux 9, or RHEL 9  
- **CPU**: 4 cores (x86_64)
- **RAM**: 8 GB
- **Storage**: 50 GB free space (SSD recommended)
- **Network**: Static IP address, redundant network interfaces

### High Availability Requirements (100+ users)
- **OS**: Ubuntu 22.04 LTS, Rocky Linux 9, or RHEL 9
- **CPU**: 8+ cores per node
- **RAM**: 16+ GB per node
- **Storage**: 100+ GB (shared storage for HA)
- **Network**: Dedicated management network

## Supported Operating Systems

| OS | Version | Support Level | Notes |
|----|---------|---------------|-------|
| Ubuntu | 22.04 LTS | ✅ Full | Recommended for new deployments |
| Ubuntu | 24.04 LTS | ✅ Full | Latest LTS release |
| Rocky Linux | 9.x | ✅ Full | RHEL alternative |
| RHEL | 9.x | ✅ Full | Enterprise support available |
| Fedora | 38+ | ⚠️ Testing | Latest features, less stable |
| Debian | 12+ | ⚠️ Testing | Community supported |
| CentOS Stream | 9 | ⚠️ Testing | Limited testing |

## Installation Methods

### Method 1: Quick Install (Recommended)

The fastest way to get AD-Stack running for evaluation or small deployments.

```bash
# Download and run the installer
curl -fsSL https://install.ad-stack.org | sudo bash

# Follow the interactive setup wizard
sudo ad-stack init --domain example.local --admin-password 'SecurePassword123!'
```

**What it does**:
- Installs Docker and Docker Compose
- Downloads AD-Stack containers
- Configures basic domain settings
- Starts all services
- Creates admin user

**Time to complete**: 15-30 minutes

---

### Method 2: Docker Compose

For users who prefer manual control over the installation process.

#### Prerequisites
```bash
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
sudo systemctl enable --now docker

# Install Docker Compose V2
sudo apt update && sudo apt install docker-compose-plugin
```

#### Installation Steps
```bash
# Clone the repository
git clone https://github.com/fahertym/AD-Stack.git
cd AD-Stack

# Copy and edit environment configuration
cp docker/dev/.env.example docker/dev/.env
nano docker/dev/.env

# Start the services
docker compose -f docker/dev/docker-compose.yml up -d

# Initialize the domain
docker exec ad-stack-orchestrator ad-stack init \
  --domain example.local \
  --admin-password 'SecurePassword123!'
```

#### Environment Configuration
Edit `docker/dev/.env`:
```bash
# Domain Configuration
AD_DOMAIN=example.local
AD_REALM=EXAMPLE.LOCAL
AD_ADMIN_PASSWORD=SecurePassword123!

# Network Configuration  
AD_SERVER_IP=192.168.1.100
AD_DNS_FORWARDERS=8.8.8.8,8.8.4.4

# Database Configuration
POSTGRES_PASSWORD=secure_db_password_here
REDIS_PASSWORD=secure_redis_password_here

# Security
JWT_SECRET=your-256-bit-secret-key-here
ENCRYPTION_KEY=your-encryption-key-here
```

**Time to complete**: 45-60 minutes

---

### Method 3: Ansible Automation

For production deployments and infrastructure-as-code workflows.

#### Prerequisites
```bash
# Install Ansible
sudo apt update && sudo apt install ansible-core
pip3 install ansible-runner

# Install required collections
ansible-galaxy collection install community.docker
ansible-galaxy collection install kubernetes.core
```

#### Installation Steps
```bash
# Clone the repository
git clone https://github.com/fahertym/AD-Stack.git
cd AD-Stack/ansible

# Copy and edit inventory
cp inventory/hosts.example inventory/hosts
nano inventory/hosts

# Copy and edit variables
cp inventory/group_vars/all.yml.example inventory/group_vars/all.yml
nano inventory/group_vars/all.yml

# Run the playbook
ansible-playbook -i inventory/hosts playbooks/deploy-ad-stack.yml
```

#### Inventory Configuration
Edit `inventory/hosts`:
```ini
[ad_stack_servers]
ad-primary ansible_host=192.168.1.100 ansible_user=ubuntu
ad-secondary ansible_host=192.168.1.101 ansible_user=ubuntu

[ad_stack_servers:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_become=yes
```

#### Variables Configuration
Edit `inventory/group_vars/all.yml`:
```yaml
# Domain settings
ad_domain: example.local
ad_realm: EXAMPLE.LOCAL
ad_admin_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256;secure_password_here

# Network settings
ad_server_ip: 192.168.1.100
ad_dns_forwarders:
  - 8.8.8.8
  - 8.8.4.4

# Deployment settings
deployment_mode: production
high_availability: false
backup_enabled: true
monitoring_enabled: true
```

**Time to complete**: 30-45 minutes (after configuration)

---

### Method 4: Kubernetes

For cloud-native deployments and larger scale environments.

#### Prerequisites
```bash
# Install kubectl and helm
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### Installation Steps
```bash
# Add AD-Stack Helm repository
helm repo add ad-stack https://helm.ad-stack.org
helm repo update

# Create namespace
kubectl create namespace ad-stack

# Install with Helm
helm install ad-stack ad-stack/ad-stack \
  --namespace ad-stack \
  --set domain.name=example.local \
  --set admin.password=SecurePassword123! \
  --set persistence.enabled=true \
  --set ingress.enabled=true
```

**Time to complete**: 20-30 minutes (with existing K8s cluster)

---

## Post-Installation Configuration

### 1. Access the Web Console

After installation, access the web interface:
```
https://your-server-ip:9090
```

Default credentials:
- **Username**: administrator
- **Password**: (password set during installation)

### 2. Verify Services

Check that all services are running:
```bash
# Docker Compose deployment
docker compose ps

# Kubernetes deployment  
kubectl get pods -n ad-stack

# Service status via CLI
ad-stack status
```

### 3. Configure DNS

Update your network's DNS settings to point to the AD-Stack server:

#### Option A: Router Configuration
Configure your router to use the AD-Stack server as the primary DNS server.

#### Option B: Client Configuration
Manually configure client machines to use the AD-Stack DNS server.

#### Option C: DHCP Server
Configure your DHCP server to provide the AD-Stack server as the DNS server.

### 4. Certificate Installation

Install the AD-Stack CA certificate on client machines:

```bash
# Download CA certificate
wget https://your-ad-server/ca.crt

# Install on Ubuntu/Debian
sudo cp ca.crt /usr/local/share/ca-certificates/ad-stack-ca.crt
sudo update-ca-certificates

# Install on RHEL/Rocky
sudo cp ca.crt /etc/pki/ca-trust/source/anchors/ad-stack-ca.crt
sudo update-ca-trust
```

### 5. Create First Users

```bash
# Using CLI
ad-stack user create johndoe \
  --full-name "John Doe" \
  --email "john@example.local" \
  --password "UserPassword123!"

# Using Web Console
# Navigate to Users → Create User
```

### 6. Join Client Machines

#### Windows Clients
```powershell
# Run as Administrator
Add-Computer -DomainName example.local -Credential (Get-Credential)
Restart-Computer
```

#### Linux Clients
```bash
# Ubuntu/Debian
sudo apt install realmd sssd-tools sssd libnss-sss libpam-sss adcli
sudo realm join example.local

# RHEL/Rocky
sudo dnf install realmd sssd oddjob oddjob-mkhomedir adcli
sudo realm join example.local
```

## Troubleshooting

### Common Issues

#### 1. DNS Resolution Problems
```bash
# Check DNS configuration
dig @localhost example.local
nslookup example.local localhost

# Verify DNS service
systemctl status systemd-resolved
```

#### 2. Time Synchronization Issues
```bash
# Install and configure NTP
sudo apt install chrony
sudo systemctl enable --now chrony

# Check time sync
timedatectl status
```

#### 3. Firewall Issues
```bash
# Ubuntu/Debian
sudo ufw allow 53,88,389,636,443,464/tcp
sudo ufw allow 53,88,464/udp

# RHEL/Rocky
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=kerberos
sudo firewall-cmd --permanent --add-service=ldap
sudo firewall-cmd --permanent --add-service=ldaps
sudo firewall-cmd --reload
```

#### 4. Service Startup Issues
```bash
# Check service logs
docker logs ad-stack-orchestrator
journalctl -u ad-stack-orchestrator

# Restart services
docker compose restart
systemctl restart ad-stack-orchestrator
```

### Getting Help

#### 1. Documentation
- **User Guide**: https://docs.ad-stack.org/user-guide
- **Administrator Guide**: https://docs.ad-stack.org/admin-guide
- **API Documentation**: https://docs.ad-stack.org/api

#### 2. Community Support
- **GitHub Discussions**: https://github.com/fahertym/AD-Stack/discussions
- **Discord Community**: https://discord.gg/ad-stack
- **Stack Overflow**: Tag your questions with `ad-stack`

#### 3. Professional Support
- **Enterprise Support**: enterprise@ad-stack.org
- **Consulting Services**: consulting@ad-stack.org
- **Training Programs**: training@ad-stack.org

## Security Considerations

### 1. Network Security
- Use strong passwords for all accounts
- Configure firewall rules appropriately
- Enable SSL/TLS for all communications
- Implement network segmentation

### 2. Access Control
- Create separate admin accounts for each administrator
- Use principle of least privilege
- Enable audit logging
- Regular security updates

### 3. Backup Strategy
- Regular automated backups
- Test restore procedures
- Offsite backup storage
- Document recovery procedures

### 4. Monitoring
- Enable system monitoring
- Configure alerting for critical events
- Regular security audits
- Monitor authentication logs

## Next Steps

After successful installation:

1. **Read the User Guide**: Familiarize yourself with AD-Stack features
2. **Configure Policies**: Set up group policies for your organization
3. **Setup File Shares**: Create network file shares for users
4. **Enable Monitoring**: Configure monitoring and alerting
5. **Plan Backups**: Implement backup and disaster recovery procedures
6. **Join the Community**: Connect with other AD-Stack users

## Migration from Existing Systems

### From Windows Active Directory
- **Assessment**: Use the migration assessment tool
- **Planning**: Review the migration planning guide
- **Execution**: Follow the Windows AD migration procedure
- **Validation**: Verify all functionality after migration

### From Other LDAP Systems
- **FreeIPA**: Use the FreeIPA migration tools
- **OpenLDAP**: Follow the OpenLDAP migration guide
- **Other**: Contact support for custom migration assistance

For detailed migration procedures, see the [Migration Guide](migration.md).