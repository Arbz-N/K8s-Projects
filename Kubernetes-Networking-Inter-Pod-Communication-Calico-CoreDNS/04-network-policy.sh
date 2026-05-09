#!/usr/bin/env bash
# 04-network-policy.sh
# Writes the Network Policy manifests to disk, applies them, and runs
# both allow and block tests to confirm enforcement is working.
#
# Prerequisites: Calico must be installed (03-install-calico.sh)
#                nginx-pod1 and nginx-pod2 must exist (02-inter-pod-comms.sh)
# Usage        : bash 04-network-policy.sh

set -euo pipefail

# Retrieve pod2 IP for testing.
POD2_IP=$(kubectl get pod nginx-pod2 \
  -o=jsonpath='{.status.podIP}' 2>/dev/null \
  || { echo "[FAIL] nginx-pod2 not found. Run 02-inter-pod-comms.sh first."; exit 1; })
echo "[INFO] nginx-pod2 IP: ${POD2_IP}"

# ─────────────────────────────────────────────
# Write and apply the allow-nginx-only policy
# ─────────────────────────────────────────────
echo "[INFO] Writing allow-nginx-ingress.yaml..."
cat > allow-nginx-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx-only
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nginx
EOF
# This policy selects all pods labelled app=nginx and permits ingress
# only from other pods that also carry app=nginx.
# Any pod without this label is blocked from sending traffic to nginx pods.

echo "[INFO] Applying allow-nginx-only policy..."
kubectl apply -f allow-nginx-ingress.yaml
kubectl get networkpolicy
kubectl describe networkpolicy allow-nginx-only

# ─────────────────────────────────────────────
# Write and apply the deny-all baseline policy
# ─────────────────────────────────────────────
echo "[INFO] Writing deny-all-policy.yaml..."
cat > deny-all-policy.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
EOF
# podSelector: {} selects every pod in the namespace.
# No ingress rules means all ingress traffic is denied by default.
# Apply deny-all first, then build allow rules on top (whitelist model).

echo "[INFO] Applying deny-all-ingress policy..."
kubectl apply -f deny-all-policy.yaml

# ─────────────────────────────────────────────
# Test 1: Allowed pod (nginx-pod1 -> nginx-pod2)
# Both pods carry app=nginx so ingress should be permitted.
# ─────────────────────────────────────────────
echo ""
echo "[INFO] Test 1 — Allow test: nginx-pod1 -> nginx-pod2 (should succeed)..."
kubectl exec nginx-pod1 -- curl -s --max-time 5 "${POD2_IP}" | grep "Welcome to nginx" \
  && echo "[OK] Traffic allowed — Network Policy permitting nginx-to-nginx correctly" \
  || echo "[FAIL] Expected nginx response not received"

# ─────────────────────────────────────────────
# Test 2: Blocked pod (busybox test-pod -> nginx-pod2)
# test-pod has no app=nginx label — ingress should be denied.
# ─────────────────────────────────────────────
echo ""
echo "[INFO] Test 2 — Block test: busybox test-pod -> nginx-pod2 (should time out)..."
kubectl run test-pod \
  --image=busybox \
  --rm -it \
  --restart=Never \
  -- wget -O- --timeout=5 "${POD2_IP}" 2>&1 | tail -3 \
  && echo "[WARN] Connection succeeded — Network Policy may not be enforced yet" \
  || echo "[OK] Connection blocked — Network Policy working correctly"
# --rm deletes test-pod automatically after the command completes.
# A timeout or connection refused is the expected and correct result.

echo ""
echo "[OK] Network Policy configuration complete."