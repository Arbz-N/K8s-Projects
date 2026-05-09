#!/usr/bin/env bash
# 00-install-minikube.sh
# Full Minikube setup on an EC2 Ubuntu 22.04 instance.
# Installs Docker, kubectl, and Minikube, then starts the cluster and runs a
# connectivity test.
#
# Prerequisites: Ubuntu 22.04, t3.medium or larger (2 vCPU, 4 GB RAM)
# Usage        : bash 00-install-minikube.sh

set -euo pipefail

echo "[INFO] Step 1 — Updating system packages..."
sudo apt update -y && sudo apt upgrade -y


echo "[INFO] Step 2 — Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
# enable ensures Docker restarts automatically after an instance reboot.

# Add the current user to the docker group so Minikube can call Docker
# without sudo. newgrp applies the group change in the current shell
# without requiring a full logout/login cycle.
sudo usermod -aG docker "$USER"
newgrp docker

docker --version && echo "[OK] Docker installed"
docker ps > /dev/null && echo "[OK] Docker daemon responding"

# ─────────────────────────────────────────────
# kubectl
# ─────────────────────────────────────────────
echo "[INFO] Step 3 — Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
  https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# The inner curl fetches the latest stable version string (e.g. v1.30.0),
# which the outer curl uses to build the correct download URL.

chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client && echo "[OK] kubectl installed"

# ─────────────────────────────────────────────
# Minikube
# ─────────────────────────────────────────────
echo "[INFO] Step 4 — Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube version && echo "[OK] Minikube installed"

# ─────────────────────────────────────────────
# Start Minikube
# ─────────────────────────────────────────────
echo "[INFO] Step 5 — Starting Minikube with Docker driver (3-5 minutes)..."
minikube start --driver=docker
# --driver=docker tells Minikube to run Kubernetes components inside Docker
# containers rather than a VM. Required on EC2 where nested virtualization
# is not available.

echo "[INFO] Verifying cluster status..."
minikube status
kubectl get nodes
# [OK] Node should show STATUS=Ready and ROLES=control-plane

kubectl get pods -A
# [OK] All pods in kube-system should reach Running state

# ─────────────────────────────────────────────
# Addons
# ─────────────────────────────────────────────
echo "[INFO] Step 6 — Enabling Minikube addons..."
minikube addons enable metrics-server
# metrics-server enables kubectl top nodes/pods for CPU and memory usage.

minikube addons enable dashboard
# dashboard provides the web UI (optional — useful for visual cluster inspection).

minikube addons list | grep enabled
echo "[OK] Addons enabled"

# ─────────────────────────────────────────────
# Connectivity test
# ─────────────────────────────────────────────
echo "[INFO] Step 7 — Running connectivity test pod..."
kubectl run hello --image=nginx --port=80

kubectl wait --for=condition=Ready pod/hello --timeout=60s
# Wait blocks until the pod reaches Ready state or the timeout expires.
# 60 seconds is sufficient for pulling the nginx image on a fresh cluster.

kubectl get pod hello
echo "[OK] Test pod is Running"

kubectl delete pod hello
echo "[OK] Test pod deleted"

echo ""
echo "[OK] Minikube setup complete. Proceed to Task 1."