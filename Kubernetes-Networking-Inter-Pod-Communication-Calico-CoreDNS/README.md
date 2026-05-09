Kubernetes Networking — Inter-Pod Communication, Calico, and CoreDNS

    Overview
    This lab covers Kubernetes networking fundamentals on a Minikube cluster running
    on an EC2 instance. Topics include verifying inter-pod communication using Pod IPs,
    enforcing network isolation with Calico Network Policies, and resolving services
    by name using CoreDNS.
    Key highlights:
    
    Minikube installed on EC2 using Docker as the driver
    Two Nginx pods communicate directly via Pod IPs before policy enforcement
    Calico Network Policy restricts ingress to only pods with the app=nginx label
    A deny-all policy establishes a whitelist baseline before allow rules are added
    CoreDNS resolves nginx-service.default.svc.cluster.local from inside a pod

Project Structure:

    k8s-networking-lab/
    ├── README.md                  <- This file (includes all YAML content inline)
    ├── 00-install-minikube.sh     <- Full Minikube setup on EC2
    ├── 01-verify-cluster.sh       <- Cluster connection and pod health checks
    ├── 02-inter-pod-comms.sh      <- Create pods and test direct IP communication
    ├── 03-install-calico.sh       <- Install Calico (Minikube addon method)
    ├── 04-network-policy.sh       <- Apply Network Policies and run block tests
    ├── 05-coredns-discovery.sh    <- Expose service and verify DNS resolution
    ├── 06-verify-all.sh           <- End-to-end summary verification
    └── cleanup.sh                 <- Delete all lab resources