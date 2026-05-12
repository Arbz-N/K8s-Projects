#!/usr/bin/env bash
# 01-verify-cluster.sh
# Verifies cluster connectivity, node readiness, and CoreDNS health.
#
# Usage: bash 01-verify-cluster.sh

set -euo pipefail

echo "[INFO] Cluster info..."
kubectl cluster-info
# Shows the control plane and CoreDNS URLs for the cluster.

echo ""
echo "[INFO] Nodes..."
kubectl get nodes
# [OK] All nodes should show STATUS=Ready before proceeding.

echo ""
echo "[INFO] All pods (all namespaces)..."
kubectl get pods --all-namespaces
# [OK] kube-system pods should all be Running or Completed.

echo ""
echo "[INFO] CoreDNS pods..."
kubectl get pods -n kube-system | grep coredns
# CoreDNS is the cluster DNS server. If it is not Running,
# service discovery in Task 5 will not work.

COREDNS_STATUS=$(kubectl get pods -n kube-system \
  -l k8s-app=kube-dns \
  --no-headers \
  -o custom-columns=":status.phase" 2>/dev/null | head -1)

if [ "${COREDNS_STATUS}" = "Running" ]; then
  echo "[OK] CoreDNS is Running"
else
  echo "[WARN] CoreDNS status: ${COREDNS_STATUS} — check events with kubectl describe"
fi