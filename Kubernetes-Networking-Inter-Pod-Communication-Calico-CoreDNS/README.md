# Kubernetes Networking — Inter-Pod Communication, Calico, and CoreDNS

    
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

k8s-networking-lab/
├── README.md                    <- This file (all commands and YAML inline)
├── allow-nginx-ingress.yaml     <- NetworkPolicy: allow nginx-to-nginx only
└── deny-all-policy.yaml         <- NetworkPolicy: deny all ingress baseline