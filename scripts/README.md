# Scripts Directory

This directory contains useful bash scripts for monitoring, checking, and verifying your Kubernetes, Minikube, MongoDB, and MongoExpress setup.

## Available Scripts

### 1. `quick-check.sh`
**Quick one-liner status check of all components**

Shows current status of:
- System uptime, memory, and load
- Docker containers
- Minikube cluster
- Kubernetes cluster
- MongoDB pod
- MongoExpress pod
- Port forwarding

Usage:
```bash
./quick-check.sh
```

Output is concise and ideal for quick status verification.

---

### 2. `check-server-resources.sh`
**Comprehensive Ubuntu server resource monitoring**

Displays:
- System uptime
- Memory usage details
- CPU information and load average
- Disk usage
- Minikube storage allocation
- Top 5 processes by memory
- Top 5 processes by CPU
- Docker container stats
- Minikube cluster status
- Kubernetes nodes
- Port 8081 (MongoExpress) status
- System hostname
- Kernel version
- Network interfaces

Usage:
```bash
./check-server-resources.sh
```

Great for detailed resource analysis and monitoring.

---

### 3. `check-minikube-status.sh`
**Detailed Minikube and Kubernetes status check**

Shows:
- Minikube version
- Minikube status
- Minikube IP address
- Minikube profiles configuration
- Kubernetes client version
- Current Kubernetes context
- Cluster info
- Nodes details
- All namespaces
- Kube-system pods
- Storage classes
- Docker version
- Minikube container info

Usage:
```bash
./check-minikube-status.sh
```

Perfect for verifying complete Minikube/Kubernetes setup.

---

### 4. `check-mongo-deployment.sh`
**MongoDB and MongoExpress deployment status**

Displays:
- All Kubernetes resources in default namespace
- MongoDB deployment details
- MongoExpress deployment details
- MongoDB pod details
- MongoExpress pod details
- MongoDB pod logs (last 20 lines)
- MongoExpress pod logs (last 20 lines)
- Services
- PersistentVolumeClaims
- PersistentVolumes
- Secrets
- ConfigMaps
- Port-forward status
- kubectl port-forward service status

Usage:
```bash
./check-mongo-deployment.sh
```

Ideal for troubleshooting MongoDB and MongoExpress issues.

---

### 5. `verify-setup.sh`
**Complete setup verification with color-coded status**

Comprehensive verification including:
- ✓ System requirements (OS, CPU, memory, disk)
- ✓ Docker installation and daemon status
- ✓ kubectl installation
- ✓ Minikube installation and cluster status
- ✓ Kubernetes cluster accessibility
- ✓ MongoDB and MongoExpress deployment status
- ✓ Services availability
- ✓ Storage (PVC status)
- ✓ Port-forwarding status
- ✓ Secrets configuration

Color-coded output:
- **✓ (Green)** - OK
- **⚠ (Yellow)** - Warning/Not found
- **✗ (Red)** - Failed

Usage:
```bash
./verify-setup.sh
```

Best for comprehensive setup validation before deployment or after troubleshooting.

---

## Quick Reference

| Script | Purpose | When to Use |
|--------|---------|------------|
| `quick-check.sh` | Fast status overview | Daily monitoring, quick verification |
| `check-server-resources.sh` | Resource monitoring | Performance analysis, troubleshooting |
| `check-minikube-status.sh` | Minikube details | Setup verification, version checking |
| `check-mongo-deployment.sh` | Deployment details | Debugging, pod inspection |
| `verify-setup.sh` | Complete validation | Initial setup, comprehensive checks |

---

## Usage Examples

### Run all checks
```bash
echo "Quick Check:" && ./quick-check.sh
echo -e "\nServer Resources:" && ./check-server-resources.sh
echo -e "\nMinikube Status:" && ./check-minikube-status.sh
echo -e "\nDeployment Status:" && ./check-mongo-deployment.sh
echo -e "\nSetup Verification:" && ./verify-setup.sh
```

### Create an alias for quick access
Add to your `.bashrc` or `.zshrc`:
```bash
alias quick-check="cd ~/repo/kubernetes-kubectl-commands/scripts && ./quick-check.sh"
alias server-check="cd ~/repo/kubernetes-kubectl-commands/scripts && ./check-server-resources.sh"
alias minikube-check="cd ~/repo/kubernetes-kubectl-commands/scripts && ./check-minikube-status.sh"
alias mongo-check="cd ~/repo/kubernetes-kubectl-commands/scripts && ./check-mongo-deployment.sh"
alias verify="cd ~/repo/kubernetes-kubectl-commands/scripts && ./verify-setup.sh"
```

Then you can run them from anywhere:
```bash
quick-check
server-check
minikube-check
mongo-check
verify
```

---

## Troubleshooting

If scripts don't run, ensure they're executable:
```bash
chmod +x *.sh
```

Some commands may require `sudo` (especially systemd status checks). Run with sudo if needed:
```bash
sudo ./check-mongo-deployment.sh
```

---

## Requirements

- Bash shell
- kubectl (for Kubernetes checks)
- docker (for Docker checks)
- minikube (for Minikube checks)
- Standard Linux utilities: `uptime`, `free`, `df`, `ps`, `ss`, `ip`, `hostnamectl`, `uname`

---

## Notes

- Scripts use colors and Unicode characters for better readability
- All scripts are non-destructive (read-only operations)
- Some commands require appropriate permissions (may need `sudo`)
- Scripts are compatible with Ubuntu 22.04 LTS and later

