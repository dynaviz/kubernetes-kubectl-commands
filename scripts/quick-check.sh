#!/bin/bash
#
# quick-check.sh
# Quick one-liner checks for all components
# Usage: ./quick-check.sh
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Quick System Check                                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "System:"
echo "  Uptime: $(uptime | awk '{print $1, $2, $3}')"
echo "  Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "  Load: $(uptime | awk -F'load average:' '{print $2}' | xargs)"

echo ""
echo "Docker:"
if docker ps -q 2>/dev/null | wc -l | grep -q "^0$"; then
    echo "  Status: No containers running"
else
    echo "  Status: $(docker ps -q 2>/dev/null | wc -l) containers running"
fi

echo ""
echo "Minikube:"
if minikube status 2>/dev/null | grep -q "Running"; then
    echo "  Status: Running"
    echo "  IP: $(minikube ip 2>/dev/null)"
else
    echo "  Status: Not running"
fi

echo ""
echo "Kubernetes:"
if kubectl cluster-info &> /dev/null; then
    echo "  Status: Cluster accessible"
    echo "  Nodes: $(kubectl get nodes --no-headers 2>/dev/null | wc -l)"
else
    echo "  Status: Cluster not accessible"
fi

echo ""
echo "MongoDB:"
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$MONGO_POD" ]; then
    MONGO_STATUS=$(kubectl get pod "$MONGO_POD" -o jsonpath='{.status.phase}' 2>/dev/null)
    echo "  Pod: $MONGO_POD"
    echo "  Status: $MONGO_STATUS"
else
    echo "  Status: No pod found"
fi

echo ""
echo "MongoExpress:"
ME_POD=$(kubectl get pods -l app=mongo-express -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$ME_POD" ]; then
    ME_STATUS=$(kubectl get pod "$ME_POD" -o jsonpath='{.status.phase}' 2>/dev/null)
    echo "  Pod: $ME_POD"
    echo "  Status: $ME_STATUS"
else
    echo "  Status: No pod found"
fi

echo ""
echo "Port-Forward:"
if ss -tlnp 2>/dev/null | grep -q 8081; then
    echo "  Port 8081: Listening ✓"
else
    echo "  Port 8081: Not listening ✗"
fi

echo ""
echo "╚════════════════════════════════════════════════════════════════╝"
