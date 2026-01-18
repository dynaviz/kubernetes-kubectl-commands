#!/bin/bash
#
# check-mongo-deployment.sh
# Check MongoDB and MongoExpress deployment status
# Usage: ./check-mongo-deployment.sh
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        MongoDB & MongoExpress Deployment Status               ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "=== All Resources in Default Namespace ==="
kubectl get all

echo ""
echo "=== MongoDB Deployment ==="
kubectl get deployment mongo-deployment -o wide

echo ""
echo "=== MongoExpress Deployment ==="
kubectl get deployment mongo-express -o wide

echo ""
echo "=== MongoDB Pod Details ==="
kubectl get pods -l app=mongodb -o wide

echo ""
echo "=== MongoExpress Pod Details ==="
kubectl get pods -l app=mongo-express -o wide

echo ""
echo "=== MongoDB Pod Logs (last 20 lines) ==="
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$MONGO_POD" ]; then
    echo "Pod: $MONGO_POD"
    kubectl logs "$MONGO_POD" --tail=20
else
    echo "No MongoDB pod found"
fi

echo ""
echo "=== MongoExpress Pod Logs (last 20 lines) ==="
ME_POD=$(kubectl get pods -l app=mongo-express -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$ME_POD" ]; then
    echo "Pod: $ME_POD"
    kubectl logs "$ME_POD" --tail=20
else
    echo "No MongoExpress pod found"
fi

echo ""
echo "=== Services ==="
kubectl get services

echo ""
echo "=== PersistentVolumeClaims ==="
kubectl get pvc

echo ""
echo "=== PersistentVolumes ==="
kubectl get pv

echo ""
echo "=== Secrets ==="
kubectl get secrets

echo ""
echo "=== ConfigMaps ==="
kubectl get configmaps

echo ""
echo "=== Port-Forward Status ==="
if ss -tlnp 2>/dev/null | grep -q 8081; then
    echo "✓ Port 8081 is listening"
    ss -tlnp 2>/dev/null | grep 8081
else
    echo "✗ Port 8081 is NOT listening"
fi

echo ""
echo "=== kubectl port-forward Service Status ==="
sudo systemctl status kubectl-portforward.service --no-pager 2>/dev/null || echo "Service not found or requires sudo"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Deployment Check Complete                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
