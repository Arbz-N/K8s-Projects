# Kubernetes Ingress with TLS on Kind Cluster


    Overview
    IngressKind is a hands-on project that demonstrates Kubernetes Ingress with HTTP and HTTPS routing on a local Kind cluster. 
    It covers NGINX Ingress Controller installation, host-based routing, self-signed TLS certificate generation, Kubernetes TLS Secrets, 
    and multi-path routing — all running locally with no cloud account required.
    
    Key highlights:
    Kind cluster configured with extraPortMappings to forward host ports 80 and 443
    NGINX Ingress Controller installed via the official Kind-specific manifest
    Caddy pod used as a lightweight backend web server
    HTTP Ingress configured for example.com with /etc/hosts local override
    Self-signed TLS certificate generated with openssl and stored as a Kubernetes Secret
    HTTPS Ingress configured with the TLS secret for SSL termination
    Multi-path routing example with nginx.ingress.kubernetes.io/rewrite-target annotation

Project Structure

