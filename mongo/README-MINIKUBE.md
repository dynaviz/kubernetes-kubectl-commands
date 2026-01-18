# Minikube Installation Guide

This guide documents the Minikube setup used for this MongoDB + MongoExpress deployment.

## Current Environment Specifications

- **OS:** Ubuntu 22.04.5 LTS (Jammy Jellyfish)
- **Minikube Version:** v1.37.0
- **Kubernetes Version:** v1.34.0
- **Driver:** Docker
- **Runtime:** Docker v29.0.3
- **kubectl Version:** v1.35.0
- **Minikube IP:** 192.168.49.2
- **Nodes:** 1 (single-node cluster)

---

## Prerequisites

Before installing Minikube, ensure you have:

1. **Ubuntu 22.04 LTS** (or compatible Linux distribution)
2. **2 CPUs or more**
3. **2GB of free memory** (4GB+ recommended)
4. **20GB of free disk space**
5. **Internet connection**
6. **Virtualization enabled** in BIOS (for VM-based drivers)

Check virtualization support:
```sh
# Check if virtualization is supported
grep -E --color 'vmx|svm' /proc/cpuinfo

# If output is colored, virtualization is supported
```

---

## Installation Steps

### Step 1: Update System

```sh
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install Docker

Minikube requires a container or VM manager. We'll use Docker.

```sh
# Install Docker dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
docker --version
```

**Add your user to the docker group:**
```sh
sudo usermod -aG docker $USER

# Log out and log back in for the group change to take effect
# Or run: newgrp docker
```

**Verify Docker works without sudo:**
```sh
docker ps
```

### Step 3: Install kubectl

kubectl is the Kubernetes command-line tool.

```sh
# Download the latest kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Step 4: Install Minikube

```sh
# Download Minikube binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

### Step 5: Start Minikube

Start Minikube with Docker driver (matching our current setup):

```sh
# Start Minikube with Docker driver
minikube start --driver=docker

# This will:
# - Download Kubernetes v1.34.0 (or latest stable)
# - Create a Docker container as the Kubernetes node
# - Configure kubectl to use the Minikube cluster
```

**Verify Minikube is running:**
```sh
minikube status
```

Expected output:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Step 6: Verify Installation

```sh
# Check Minikube cluster info
kubectl cluster-info

# Check nodes
kubectl get nodes

# Check Minikube IP
minikube ip
```

---

## Verifying Your Installation

After installation, verify everything is working correctly:

### Check Minikube Status

```sh
minikube status
```

Expected output:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Check Minikube Version

```sh
minikube version
```

Expected output:
```
minikube version: v1.37.0
commit: 65318f4cfff9c12cc87ec9eb8f4cdd57b25047f3
```

### Check Minikube Profile Configuration

```sh
minikube profile list
```

Expected output:
```
┌──────────┬────────┬─────────┬──────────────┬─────────┬────────┬───────┬────────────────┬────────────────────┐
│ PROFILE  │ DRIVER │ RUNTIME │      IP      │ VERSION │ STATUS │ NODES │ ACTIVE PROFILE │ ACTIVE KUBECONTEXT │
├──────────┼────────┼─────────┼──────────────┼─────────┼────────┼───────┼────────────────┼────────────────────┤
│ minikube │ docker │ docker  │ 192.168.49.2 │ v1.34.0 │ OK     │ 1     │ *              │ *                  │
└──────────┴────────┴─────────┴──────────────┴─────────┴────────┴───────┴────────────────┴────────────────────┘
```

### Check Docker Version

```sh
docker --version
```

Expected output:
```
Docker version 29.0.3, build 511dad6
```

### Check kubectl Version

```sh
kubectl version --client
```

Expected output:
```
Client Version: v1.35.0
Kustomize Version: v5.7.1
```

Or use the short format:
```sh
kubectl version --client --short
```

Expected output:
```
Client Version: v1.35.0, Kustomize Version: v5.7.1
```

### Check Kubernetes Cluster Info

```sh
kubectl cluster-info
```

Expected output:
```
Kubernetes control plane is running at https://127.0.0.1:52697
CoreDNS is running at https://127.0.0.1:52697/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### Check Kubernetes Nodes

```sh
kubectl get nodes
```

Expected output:
```
NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   4h11m   v1.34.0
```

### Check Current Context

```sh
kubectl config current-context
```

Expected output:
```
minikube
```

### Get Minikube IP

```sh
minikube ip
```

Expected output:
```
192.168.49.2
```

### Check System Information

**Operating System:**
```sh
cat /etc/os-release | grep -E "^(NAME|VERSION)="
```

Expected output:
```
NAME="Ubuntu"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
```

**Available Memory:**
```sh
free -h
```

Expected output:
```
               total        used        free      shared  buff/cache   available
Mem:            15Gi       4.2Gi       5.2Gi       512Mi       5.6Gi       9.8Gi
Swap:          2.0Gi          0B       2.0Gi
```

**Available Disk Space:**
```sh
df -h
```

Expected output:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   45G   55G  45% /
```

**Check CPU Count:**
```sh
nproc
```

Expected output:
```
8
```

**Check CPU Info:**
```sh
lscpu
```

Expected output (excerpt):
```
Architecture:                    x86_64
CPU op-mode(s):                  32-bit, 64-bit
Byte Order:                      Little Endian
CPU(s):                          8
```

### Check Virtualization Support

```sh
grep -E --color 'vmx|svm' /proc/cpuinfo
```

If colored output appears, virtualization is supported. Example:
```
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb cat_l3 cat_l2 cdp_l3 invpcid_single intel_ppin ssbd mba ibrs ibpb stibp ibrs_enhanced tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid cqm rdt_a avx512f avx512dq rdseed adx smap avx512ifma clflushopt clwb intel_pt avx512pf avx512er avx512cd sha_ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local split_lock_detect wbnoinvd dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req hfi umip pku ospke waitpkg uintr avx512_vp2intersect avx512_bf16 ept_ad avx512_vp2intersect tsxldtrk
```

---

## Checking Docker Configuration

### Check Docker is Running

```sh
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                    COMMAND                  CREATED        STATUS       PORTS                      NAMES
a1b2c3d4e5f6   gcr.io/k8s-minikube/kicbase:v0.0.44   "/usr/local/bin/entrypoint.sh"   4 hours ago    Up 4 hours   127.0.0.1:52697->8443/tcp   minikube
```

### Check Docker Version and Info

```sh
docker version
```

Expected output (excerpt):
```
Client:
 Version:           29.0.3
 API version:       1.44
 Go version:        go1.21.9
 ...

Server:
 Version:           29.0.3
 APIversion:        1.44
 ...
```

### Check Docker Network for Minikube

```sh
docker network ls
```

Expected output:
```
NETWORK ID     NAME      DRIVER    SCOPE
a1b2c3d4e5f6   bridge    bridge    local
b2c3d4e5f6a7   host      host      local
c3d4e5f6a7b8   minikube  bridge    local
d4e5f6a7b8c9   none      null      local
```

### Inspect Minikube Network

```sh
docker network inspect minikube
```

Expected output (excerpt):
```
[
    {
        "Name": "minikube",
        "Id": "c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8",
        "Created": "2026-01-18T10:30:00.123456789Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "192.168.49.0/24",
                    "Gateway": "192.168.49.1"
                }
            ]
        },
        ...
    }
]
```

### Check Minikube Container Details

```sh
docker ps --filter "name=minikube" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```

Expected output:
```
CONTAINER ID   IMAGE                          STATUS            PORTS
a1b2c3d4e5f6   gcr.io/k8s-minikube/kicbase:v0.0.44   Up 4 hours       127.0.0.1:52697->8443/tcp
```

---

## Checking Kubernetes Resources

### Check All Nodes

```sh
kubectl get nodes -o wide
```

Expected output:
```
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
minikube   Ready    control-plane   4h11m   v1.34.0   192.168.49.2   <none>        Ubuntu 22.04.5 LTS   5.15.0-113-generic   docker://29.0.3
```

### Check All Namespaces

```sh
kubectl get namespaces
```

Expected output:
```
NAME              STATUS   AGE
default           Active   4h11m
kube-node-lease   Active   4h11m
kube-public       Active   4h11m
kube-system       Active   4h11m
```

### Check System Pods

```sh
kubectl get pods -n kube-system
```

Expected output (excerpt):
```
NAME                               READY   STATUS    RESTARTS   AGE
coredns-6d4c76bf69-abc12           1/1     Running   0          4h11m
etcd-minikube                      1/1     Running   0          4h11m
kube-apiserver-minikube            1/1     Running   0          4h11m
kube-controller-manager-minikube    1/1     Running   0          4h11m
kube-proxy-abcde                   1/1     Running   0          4h11m
kube-scheduler-minikube            1/1     Running   0          4h11m
storage-provisioner                1/1     Running   1          4h11m
```

### Check Resource Allocation

```sh
kubectl top nodes
```

Expected output:
```
NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
minikube   500m         12%    1200Mi          8%
```

### Check Available Storage Classes

```sh
kubectl get storageclass
```

Expected output:
```
NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
standard (default)   k8s.io/minikube-hostpath   Delete          Immediate           false                  4h11m
```

---

## Quick Verification Checklist

Run these commands to verify your complete setup:

```sh
#!/bin/bash
echo "=== Minikube Status ==="
minikube status

echo -e "\n=== Version Info ==="
echo "Minikube:"
minikube version
echo "Docker:"
docker --version
echo "kubectl:"
kubectl version --client --short

echo -e "\n=== Cluster Info ==="
echo "Minikube IP:"
minikube ip
echo "Kubernetes Context:"
kubectl config current-context
echo "Nodes:"
kubectl get nodes

echo -e "\n=== System Resources ==="
echo "Free Memory:"
free -h | head -2
echo "Disk Space:"
df -h | grep -E "^/dev|mounted"
echo "CPU Count:"
nproc

echo -e "\n=== Docker Info ==="
echo "Docker is running:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep minikube
echo "Minikube Network:"
docker network inspect minikube | grep -A 2 '"Subnet"'
```

Save this as `check-setup.sh`, make it executable with `chmod +x check-setup.sh`, and run it anytime you want to verify your setup!

---

## Checking Linux/Ubuntu Server Resources

Monitor your Ubuntu server's resource usage to ensure Minikube has sufficient capacity:

### Real-time Memory Usage

```sh
free -h
```

Expected output:
```
               total        used        free      shared  buff/cache   available
Mem:            15Gi       4.2Gi       5.2Gi       512Mi       5.6Gi       9.8Gi
Swap:          2.0Gi          0B       2.0Gi
```

Breakdown:
- **total**: Total installed RAM (15Gi in this case)
- **used**: Currently in use
- **free**: Completely free
- **shared**: Used by temporary file systems
- **buff/cache**: Used for buffers and cache (can be freed if needed)
- **available**: Memory available for new processes

For detailed memory info:
```sh
free -h -w
```

### Real-time CPU Usage

Check current CPU load:
```sh
uptime
```

Expected output:
```
 14:35:22 up 4:11,  2 users,  load average: 1.23, 1.15, 1.08
```

The load average shows 1-minute, 5-minute, and 15-minute averages. Compare to CPU count with `nproc`.

### CPU Details

```sh
lscpu
```

Expected output (excerpt):
```
Architecture:                    x86_64
CPU op-mode(s):                  32-bit, 64-bit
Byte Order:                      Little Endian
Address sizes:                   46 bits physical, 48 bits virtual
CPU(s):                          8
On-line CPU(s) list:             0-7
Vendor ID:                       GenuineIntel
Model name:                      Intel(R) Xeon(R) CPU @ 2.80GHz
CPU max MHz:                     2800.0000
CPU min MHz:                     800.0000
BogoMIPS:                        5600.00
Flags:                           fpu vme de pse tsc msr pae mce ...
```

Count logical CPUs:
```sh
nproc
```

Expected output:
```
8
```

### Disk Usage

Check overall disk usage:
```sh
df -h
```

Expected output:
```
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        7.9G     0  7.9G   0% /dev
tmpfs           7.9G  512M  7.4G   7% /dev/shm
tmpfs           3.2G  1.2M  3.2G   1% /run
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
/dev/sda1       100G   45G   55G  45% /
tmpfs           1.6G     0  1.6G   0% /run/user/1000
```

Check disk usage by directory:
```sh
du -sh /
```

Expected output:
```
45G	/
```

Check Minikube's Docker data location:
```sh
du -sh ~/.minikube
```

Expected output:
```
8.5G	/home/akieres/.minikube
```

### Disk I/O

Check disk I/O activity:
```sh
iostat -x 1 5
```

Expected output (shows 5 samples, 1 second interval):
```
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          15.23    0.00   8.45    2.12    0.00   74.20

Device            r/s     w/s     rMB/s     wMB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz %util
sda              45.32   78.21      1.23      3.45    12.3    34.2   21.4   30.5    5.12    8.34   0.98  12.5
```

### Network Connectivity

Check network interface status:
```sh
ip addr show
```

Expected output (excerpt):
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:50:56:c0:00:01 brd ff:ff:ff:ff:ff:ff
    inet 194.35.13.113/24 brd 194.35.13.255 scope global dynamic eth0
```

### Running Processes

List all running processes sorted by memory:
```sh
ps aux --sort=-%mem | head -15
```

Expected output:
```
USER       PID %CPU %MEM    VSZ   RSS TTY  STAT START   TIME COMMAND
root      1234  2.5 15.3 2048000 1048576 ?  Ssl  10:20   0:45 /usr/bin/dockerd
akieres   5678  1.2  8.4 1024000 524288  ?  Sl   10:25   0:30 /minikube start
akieres   9012  0.8  6.2 512000 262144   ?  Sl   10:30   0:20 kubectl proxy
```

List processes sorted by CPU:
```sh
ps aux --sort=-%cpu | head -15
```

### System Uptime and Load

```sh
uptime
```

Expected output:
```
 14:35:22 up 4:11,  2 users,  load average: 1.23, 1.15, 1.08
```

### Real-time Resource Monitoring

Use `htop` for an interactive resource monitor (install if needed):
```sh
sudo apt install htop
htop
```

Or use `top` (built-in):
```sh
top
```

Press `q` to exit.

### Check Specific Process Resources

Check Docker's resource usage:
```sh
ps aux | grep docker
```

Check Minikube container resource usage:
```sh
docker stats --no-stream
```

Expected output:
```
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O
a1b2c3d4e5f6   minikube  12.3%    1.2GiB / 15.7GiB     7.6%     12.3MB / 5.6MB    245MB / 120MB
```

### System Information Summary

Get comprehensive system info:
```sh
hostnamectl
```

Expected output:
```
 Static hostname: ubuntu-vm
       Pretty hostname: Ubuntu VM
             Chassis: vm
        Machine ID: 1234567890abcdef1234567890abcdef
           Boot ID: abcdef1234567890abcdef1234567890
    Virtualization: kvm
  Operating System: Ubuntu 22.04.5 LTS
            Kernel: Linux 5.15.0-113-generic
      Architecture: x86_64
       Hardware Vendor: QEMU
        Hardware Model: Standard PC
```

### Check Open Ports

List all listening ports:
```sh
sudo netstat -tlnp
```

Or using `ss`:
```sh
ss -tlnp
```

Expected output (excerpt):
```
State   Recv-Q  Send-Q  Local Address:Port  Peer Address:Port  Process
LISTEN  0       128     0.0.0.0:22         0.0.0.0:*         systemd-resolved
LISTEN  0       128     0.0.0.0:8081       0.0.0.0:*         kubectl port-forward
LISTEN  0       128     127.0.0.1:52697    0.0.0.0:*         docker-proxy
```

Specifically check for port 8081 (MongoExpress port-forward):
```sh
netstat -tlnp | grep 8081
```

### Check Running Services

List system services and their status:
```sh
sudo systemctl list-units --type=service --all
```

Or check specific service (kubectl port-forward):
```sh
sudo systemctl status kubectl-portforward.service --no-pager
```

### Memory Cache and Buffer Info

```sh
cat /proc/meminfo
```

Expected output (excerpt):
```
MemTotal:       16389872 kB
MemFree:        5452160 kB
MemAvailable:   10277888 kB
Buffers:        237568 kB
Cached:         4588160 kB
SwapCached:     0 kB
...
```

### CPU Usage Per Core

```sh
mpstat -P ALL 1 5
```

Expected output:
```
Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %guest  %gnice   %idle
Average:       0   15.2    0.0     8.3    2.1     0.1    0.2     0.0     0.0    74.1
Average:       1   12.5    0.0     7.8    1.9     0.0    0.3     0.0     0.0    77.5
Average:       2   18.3    0.0     9.1    2.4     0.2    0.3     0.0     0.0    69.7
Average:       3   14.1    0.0     8.0    2.0     0.1    0.2     0.0     0.0    75.6
```

### Server Resource Check Script

Create a comprehensive server resource monitoring script:

```sh
#!/bin/bash
echo "=== Ubuntu Server Resource Report ==="
echo "Timestamp: $(date)"

echo -e "\n=== System Uptime ==="
uptime

echo -e "\n=== Memory Usage ==="
free -h

echo -e "\n=== CPU Information ==="
echo "CPU Count: $(nproc)"
uptime | awk -F'load average:' '{print "Load Average: " $2}'

echo -e "\n=== Disk Usage ==="
df -h | grep -E "^/dev|mounted"

echo -e "\n=== Minikube Storage ==="
du -sh ~/.minikube 2>/dev/null || echo "Minikube not found"

echo -e "\n=== Top 5 Processes by Memory ==="
ps aux --sort=-%mem | head -6

echo -e "\n=== Top 5 Processes by CPU ==="
ps aux --sort=-%cpu | head -6

echo -e "\n=== Docker Stats ==="
docker stats --no-stream 2>/dev/null | head -5 || echo "Docker not running"

echo -e "\n=== Open Port 8081 (MongoExpress) ==="
netstat -tlnp 2>/dev/null | grep 8081 || echo "Port 8081 not listening"

echo -e "\n=== System Hostname ==="
hostnamectl | grep "hostname\|System"

echo -e "\n=== Kernel Version ==="
uname -r

echo "=== End of Report ==="
```

Save this as `server-resources.sh`, make it executable with `chmod +x server-resources.sh`, and run it anytime you need a server resource summary!

---

## Minikube Configuration

### Current Configuration Used

```sh
# Profile: minikube (default)
# Driver: docker
# Runtime: docker
# Kubernetes: v1.34.0
# Nodes: 1
# IP: 192.168.49.2
```

### Useful Minikube Commands

**Start/Stop Minikube:**
```sh
# Start Minikube
minikube start

# Stop Minikube (keeps state)
minikube stop

# Delete Minikube cluster (removes all data)
minikube delete
```

**Check Status:**
```sh
# Check status
minikube status

# View profile list
minikube profile list

# Check IP address
minikube ip
```

**Access Services:**
```sh
# Get service URL
minikube service <service-name> --url

# Open service in browser
minikube service <service-name>

# List all service URLs
minikube service list
```

**Manage Addons:**
```sh
# List available addons
minikube addons list

# Enable an addon
minikube addons enable <addon-name>

# Disable an addon
minikube addons disable <addon-name>
```

**Dashboard:**
```sh
# Open Kubernetes dashboard
minikube dashboard

# Get dashboard URL only
minikube dashboard --url
```

**SSH into Minikube node:**
```sh
minikube ssh
```

**Check logs:**
```sh
minikube logs
```

---

## Configuring Minikube for Production-like Setup

### Increase Resources (if needed)

```sh
# Stop Minikube first
minikube stop

# Delete existing cluster
minikube delete

# Start with custom resources
minikube start \
  --driver=docker \
  --cpus=4 \
  --memory=8192 \
  --disk-size=50g
```

### Set Default Driver

```sh
# Set Docker as default driver
minikube config set driver docker

# Verify
minikube config view
```

---

## Network Configuration for Remote Access

Since this setup is running on a remote Ubuntu VM (194.35.13.113), here's how network access is configured:

### Minikube Network Architecture

```
Internet
   ↓
VM Public IP (194.35.13.113)
   ↓
kubectl port-forward (systemd service)
   ↓
Minikube Docker Network (192.168.49.2)
   ↓
Kubernetes Services
   ↓
Pods
```

### Expose Services

Minikube services are accessible via:

1. **kubectl port-forward** (used in this setup)
   ```sh
   kubectl port-forward --address 0.0.0.0 svc/<service-name> 8081:8081
   ```

2. **minikube tunnel** (alternative method)
   ```sh
   minikube tunnel
   ```

3. **NodePort** (limited to Minikube IP)
   - Services accessible at `http://192.168.49.2:<nodePort>`

---

## Troubleshooting Minikube

### Minikube Won't Start

```sh
# Check Docker is running
docker ps

# Check system resources
free -h
df -h

# Try deleting and recreating
minikube delete
minikube start --driver=docker

# Check logs
minikube logs
```

### kubectl Not Connecting

```sh
# Verify Minikube is running
minikube status

# Check context
kubectl config current-context

# Set context to Minikube
kubectl config use-context minikube

# Verify connection
kubectl get nodes
```

### Port Conflicts

```sh
# Check if ports are in use
sudo netstat -tlnp | grep <port>

# Kill conflicting process
sudo kill <PID>
```

### Permission Denied (Docker)

```sh
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in
# Or activate the new group
newgrp docker

# Verify
docker ps
```

### Minikube IP Not Accessible

```sh
# Check IP
minikube ip

# Try SSH into Minikube
minikube ssh

# Check Minikube network
docker network ls
docker network inspect minikube
```

---

## Upgrading Minikube

### Upgrade Minikube

```sh
# Download latest version
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify new version
minikube version

# Restart with new version
minikube stop
minikube start
```

### Upgrade Kubernetes Version

```sh
# Check available versions
minikube update-check

# Upgrade to specific version
minikube start --kubernetes-version=v1.35.0

# Or use latest
minikube start --kubernetes-version=latest
```

---

## Uninstalling Minikube

```sh
# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete --all --purge

# Remove Minikube binary
sudo rm /usr/local/bin/minikube

# Remove kubectl (if desired)
sudo rm /usr/local/bin/kubectl

# Remove configuration files
rm -rf ~/.minikube
rm -rf ~/.kube
```

---

## Additional Resources

- **Official Minikube Documentation:** https://minikube.sigs.k8s.io/docs/
- **Minikube GitHub:** https://github.com/kubernetes/minikube
- **kubectl Documentation:** https://kubernetes.io/docs/reference/kubectl/
- **Docker Documentation:** https://docs.docker.com/

---

## Quick Reference Commands

```sh
# Start Minikube
minikube start

# Stop Minikube
minikube stop

# Check status
minikube status

# Get Minikube IP
minikube ip

# SSH into node
minikube ssh

# Open dashboard
minikube dashboard

# View service URLs
minikube service list

# Get service URL
minikube service <service-name> --url

# Enable addon
minikube addons enable <addon-name>

# View logs
minikube logs

# Delete cluster
minikube delete
```

---

## Current Deployment Configuration

This MongoDB + MongoExpress setup uses:
- **Minikube** as the Kubernetes cluster
- **Docker driver** for container runtime
- **kubectl port-forward** with systemd service for external access
- **PersistentVolume** backed by Minikube's default storage class
- **NodePort services** exposed via port-forward to VM's public IP

For details on the MongoDB deployment, see the main [README.md](README.md).
