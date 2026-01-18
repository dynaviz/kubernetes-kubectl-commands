#!/bin/bash
#
# check-minikube-status.sh
# Quick Minikube and Kubernetes status check
# Usage: ./check-minikube-status.sh
#

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Minikube & Kubernetes Status Check                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "=== Minikube Version ==="
minikube version

echo ""
echo "=== Minikube Status ==="
minikube status

echo ""
echo "=== Minikube IP Address ==="
minikube ip

echo ""
echo "=== Minikube Profiles ==="
minikube profile list

echo ""
echo "=== Kubernetes Version ==="
kubectl version --client

echo ""
echo "=== Kubernetes Context ==="
kubectl config current-context

echo ""
echo "=== Kubernetes Cluster Info ==="
kubectl cluster-info

echo ""
echo "=== Kubernetes Nodes ==="
kubectl get nodes -o wide

echo ""
echo "=== All Namespaces ==="
kubectl get namespaces

echo ""
echo "=== Kube-System Pods ==="
kubectl get pods -n kube-system

echo ""
echo "=== Storage Classes ==="
kubectl get storageclass

echo ""
echo "=== Docker Version ==="
docker --version

echo ""
echo "=== Minikube Container Info ==="
docker ps --filter "name=minikube" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Status Check Complete                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
