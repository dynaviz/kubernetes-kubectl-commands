#!/bin/bash
#
# check-server-resources.sh
# Comprehensive server resource monitoring script
# Usage: ./check-server-resources.sh
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Ubuntu Server Resource Report                          ║"
echo "║        Generated: $(date '+%Y-%m-%d %H:%M:%S')                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "=== System Uptime ==="
uptime

echo ""
echo "=== Memory Usage ==="
free -h

echo ""
echo "=== CPU Information ==="
echo "CPU Count: $(nproc)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"

echo ""
echo "=== Disk Usage ==="
df -h | grep -E "^/dev|^Filesystem"

echo ""
echo "=== Minikube Storage ==="
if [ -d ~/.minikube ]; then
    du -sh ~/.minikube
else
    echo "Minikube not installed or directory not found"
fi

echo ""
echo "=== Top 5 Processes by Memory ==="
ps aux --sort=-%mem | head -6

echo ""
echo "=== Top 5 Processes by CPU ==="
ps aux --sort=-%cpu | head -6

echo ""
echo "=== Docker Stats ==="
if command -v docker &> /dev/null; then
    docker stats --no-stream 2>/dev/null | head -5 || echo "Docker not running or no containers"
else
    echo "Docker not installed"
fi

echo ""
echo "=== Minikube Cluster Status ==="
if command -v minikube &> /dev/null; then
    minikube status 2>/dev/null || echo "Minikube not running"
else
    echo "Minikube not installed"
fi

echo ""
echo "=== Kubernetes Nodes ==="
if command -v kubectl &> /dev/null; then
    kubectl get nodes 2>/dev/null || echo "Kubernetes cluster not accessible"
else
    echo "kubectl not installed"
fi

echo ""
echo "=== Open Port 8081 (MongoExpress) ==="
if ss -tlnp 2>/dev/null | grep -q 8081; then
    ss -tlnp 2>/dev/null | grep 8081
else
    echo "Port 8081 not listening"
fi

echo ""
echo "=== System Hostname ==="
hostnamectl | grep -E "hostname|System"

echo ""
echo "=== Kernel Version ==="
uname -r

echo ""
echo "=== Network Interfaces ==="
ip addr show | grep -E "^[0-9]+:|inet " | head -10

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        End of Report                                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
