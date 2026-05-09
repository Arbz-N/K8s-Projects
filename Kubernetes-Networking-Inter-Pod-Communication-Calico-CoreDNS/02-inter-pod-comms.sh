#!/usr/bin/env bash
# 02-inter-pod-comms.sh
# Creates nginx-pod1 and nginx-pod2 with app=nginx labels,
# then tests direct pod-to-pod communication using Pod IPs.
#
# Usage: bash 02-inter-pod-comms.sh

set -euo pipefail

echo "[INFO] Creating nginx-pod1..."
kubectl run nginx-pod1 \
  --image=nginx \
  --labels="app=nginx"
# --labels sets app=nginx on the pod. This label is required by the
# Network Policy in Task 4 to identify which pods are allowed to communicate.

echo "[INFO] Creating nginx-pod2..."
kubectl run nginx-pod2 \
  --image=nginx \
  --labels="app=nginx"

echo "[INFO] Waiting for both pods to reach Ready state..."
kubectl wait --for=condition=Ready pod/nginx-pod1 --timeout=60s
kubectl wait --for=condition=Ready pod/nginx-pod2 --timeout=60s

echo ""
echo "[INFO] Pod IPs:"
kubectl get pods -o wide
# -o wide includes the IP column alongside the standard pod fields.

# Extract nginx-pod2's IP for the curl test.
POD2_IP=$(kubectl get pod nginx-pod2 \
  -o=jsonpath='{.status.podIP}')
echo ""
echo "[INFO] nginx-pod2 IP: ${POD2_IP}"

echo ""
echo "[INFO] All app=nginx pod IPs:"
kubectl get pods -l app=nginx \
  -o=jsonpath='{range .items[*]}{.metadata.name}: {.status.podIP}{"\n"}{end}'
# jsonpath range iterates over each item in the pod list and prints
# the pod name alongside its IP address.

echo ""
echo "[INFO] Testing inter-pod communication (nginx-pod1 -> nginx-pod2)..."
kubectl exec nginx-pod1 -- curl -s --max-time 10 "${POD2_IP}" | grep "Welcome to nginx" \
  && echo "[OK] Inter-pod communication working" \
  || echo "[FAIL] curl did not return expected nginx response"

echo ""
echo "[INFO] Verbose test (with HTTP headers)..."
kubectl exec nginx-pod1 -- curl -v --max-time 10 "${POD2_IP}" 2>&1 | tail -20