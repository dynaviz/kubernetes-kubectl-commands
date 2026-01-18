#!/bin/bash
#
# verify-setup.sh
# Complete setup verification script
# Usage: ./verify-setup.sh
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Complete Setup Verification                            ║"
echo "║        Generated: $(date '+%Y-%m-%d %H:%M:%S')                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"

PASS="✓"
FAIL="✗"
WARN="⚠"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=== System Requirements ==="

# Check OS
if grep -q "Ubuntu" /etc/os-release; then
    echo -e "${GREEN}${PASS}${NC} Ubuntu detected"
else
    echo -e "${RED}${FAIL}${NC} Not Ubuntu"
fi

# Check CPU count
CPU_COUNT=$(nproc)
if [ "$CPU_COUNT" -ge 2 ]; then
    echo -e "${GREEN}${PASS}${NC} CPU cores: $CPU_COUNT"
else
    echo -e "${RED}${FAIL}${NC} CPU cores: $CPU_COUNT (minimum 2 recommended)"
fi

# Check memory
MEM_GB=$(free -g | awk '/^Mem:/ {print $2}')
if [ "$MEM_GB" -ge 4 ]; then
    echo -e "${GREEN}${PASS}${NC} Memory: ${MEM_GB}GB"
else
    echo -e "${YELLOW}${WARN}${NC} Memory: ${MEM_GB}GB (minimum 4GB recommended)"
fi

# Check disk space
DISK_AVAILABLE=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
if [ "$DISK_AVAILABLE" -ge 20 ]; then
    echo -e "${GREEN}${PASS}${NC} Disk available: ${DISK_AVAILABLE}GB"
else
    echo -e "${RED}${FAIL}${NC} Disk available: ${DISK_AVAILABLE}GB (minimum 20GB recommended)"
fi

echo ""
echo "=== Docker Installation ==="

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}${PASS}${NC} Docker installed: $DOCKER_VERSION"
    
    if docker ps &> /dev/null; then
        echo -e "${GREEN}${PASS}${NC} Docker daemon running"
    else
        echo -e "${RED}${FAIL}${NC} Docker daemon not running"
    fi
else
    echo -e "${RED}${FAIL}${NC} Docker not installed"
fi

echo ""
echo "=== kubectl Installation ==="

if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null)
    echo -e "${GREEN}${PASS}${NC} kubectl installed: $KUBECTL_VERSION"
else
    echo -e "${RED}${FAIL}${NC} kubectl not installed"
fi

echo ""
echo "=== Minikube Installation ==="

if command -v minikube &> /dev/null; then
    MINIKUBE_VERSION=$(minikube version 2>/dev/null | head -1)
    echo -e "${GREEN}${PASS}${NC} Minikube installed: $MINIKUBE_VERSION"
    
    if minikube status &> /dev/null | grep -q "Running"; then
        echo -e "${GREEN}${PASS}${NC} Minikube cluster running"
        MINIKUBE_IP=$(minikube ip 2>/dev/null)
        echo -e "${GREEN}${PASS}${NC} Minikube IP: $MINIKUBE_IP"
    else
        echo -e "${RED}${FAIL}${NC} Minikube cluster not running"
    fi
else
    echo -e "${RED}${FAIL}${NC} Minikube not installed"
fi

echo ""
echo "=== Kubernetes Cluster ==="

if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}${PASS}${NC} Kubernetes cluster accessible"
    
    NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    echo -e "${GREEN}${PASS}${NC} Nodes: $NODE_COUNT"
else
    echo -e "${RED}${FAIL}${NC} Kubernetes cluster not accessible"
fi

echo ""
echo "=== Deployment Status ==="

# Check MongoDB deployment
if kubectl get deployment mongo-deployment &> /dev/null; then
    MONGO_READY=$(kubectl get deployment mongo-deployment -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    MONGO_DESIRED=$(kubectl get deployment mongo-deployment -o jsonpath='{.spec.replicas}' 2>/dev/null)
    
    if [ "$MONGO_READY" = "$MONGO_DESIRED" ] && [ "$MONGO_READY" -gt 0 ]; then
        echo -e "${GREEN}${PASS}${NC} MongoDB deployment: Ready ($MONGO_READY/$MONGO_DESIRED)"
    else
        echo -e "${YELLOW}${WARN}${NC} MongoDB deployment: Not ready ($MONGO_READY/$MONGO_DESIRED)"
    fi
else
    echo -e "${YELLOW}${WARN}${NC} MongoDB deployment: Not found"
fi

# Check MongoExpress deployment
if kubectl get deployment mongo-express &> /dev/null; then
    ME_READY=$(kubectl get deployment mongo-express -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    ME_DESIRED=$(kubectl get deployment mongo-express -o jsonpath='{.spec.replicas}' 2>/dev/null)
    
    if [ "$ME_READY" = "$ME_DESIRED" ] && [ "$ME_READY" -gt 0 ]; then
        echo -e "${GREEN}${PASS}${NC} MongoExpress deployment: Ready ($ME_READY/$ME_DESIRED)"
    else
        echo -e "${YELLOW}${WARN}${NC} MongoExpress deployment: Not ready ($ME_READY/$ME_DESIRED)"
    fi
else
    echo -e "${YELLOW}${WARN}${NC} MongoExpress deployment: Not found"
fi

echo ""
echo "=== Services ==="

# Check MongoExpress service
if kubectl get service mongoexpress-service &> /dev/null; then
    echo -e "${GREEN}${PASS}${NC} MongoExpress service: Found"
else
    echo -e "${YELLOW}${WARN}${NC} MongoExpress service: Not found"
fi

# Check MongoDB service
if kubectl get service mongodb-service &> /dev/null; then
    echo -e "${GREEN}${PASS}${NC} MongoDB service: Found"
else
    echo -e "${YELLOW}${WARN}${NC} MongoDB service: Not found"
fi

echo ""
echo "=== Storage ==="

# Check PVC
if kubectl get pvc mongodb-pvc &> /dev/null; then
    PVC_STATUS=$(kubectl get pvc mongodb-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
    if [ "$PVC_STATUS" = "Bound" ]; then
        echo -e "${GREEN}${PASS}${NC} PVC mongodb-pvc: Bound"
    else
        echo -e "${YELLOW}${WARN}${NC} PVC mongodb-pvc: $PVC_STATUS"
    fi
else
    echo -e "${YELLOW}${WARN}${NC} PVC mongodb-pvc: Not found"
fi

echo ""
echo "=== Port-Forwarding ==="

# Check port 8081
if ss -tlnp 2>/dev/null | grep -q 8081; then
    echo -e "${GREEN}${PASS}${NC} Port 8081: Listening"
else
    echo -e "${RED}${FAIL}${NC} Port 8081: Not listening"
fi

# Check systemd service
if sudo systemctl is-active --quiet kubectl-portforward.service 2>/dev/null; then
    echo -e "${GREEN}${PASS}${NC} kubectl-portforward service: Active"
else
    echo -e "${YELLOW}${WARN}${NC} kubectl-portforward service: Not active"
fi

echo ""
echo "=== Secrets ==="

# Check MongoDB secret
if kubectl get secret mongodb-secret &> /dev/null; then
    echo -e "${GREEN}${PASS}${NC} MongoDB secret: Found"
else
    echo -e "${YELLOW}${WARN}${NC} MongoDB secret: Not found"
fi

# Check MongoExpress secret
if kubectl get secret mongoexpress-secret &> /dev/null; then
    echo -e "${GREEN}${PASS}${NC} MongoExpress secret: Found"
else
    echo -e "${YELLOW}${WARN}${NC} MongoExpress secret: Not found"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Verification Complete                                  ║"
echo "║        ${GREEN}${PASS}${NC} = OK  ${YELLOW}${WARN}${NC} = Warning  ${RED}${FAIL}${NC} = Failed                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
