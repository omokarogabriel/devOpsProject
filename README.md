# DevOps Portfolio — Kubernetes Projects

A comprehensive collection of production-ready Kubernetes deployments demonstrating core DevOps practices, cloud-native architecture patterns, and infrastructure automation.

## 🎯 Overview

This repository showcases hands-on expertise in container orchestration, infrastructure as code, and modern DevOps workflows. Each project demonstrates real-world scenarios with production-grade configurations, security best practices, and operational excellence.

## 📂 Projects

### [Project 1 — Nginx Ingress Demo](./project_1/)
**Focus:** Service exposure, Ingress routing, health checks

A foundational deployment demonstrating how to expose applications externally using Kubernetes Services and Ingress controllers.

**Key Features:**
- Multi-replica nginx deployment with resource management
- NodePort Service for external access
- Ingress configuration with hostname-based routing
- Comprehensive health checks (liveness & readiness probes)
- Environment-specific configuration via environment variables

**Technologies:** Kubernetes, Nginx, Ingress Controller

---

### [Project 2 — 3-Tier Application with TLS & Rolling Updates](./project_2/)
**Focus:** Multi-tier architecture, TLS/SSL, zero-downtime deployments

A production-grade three-tier application deployment with automated certificate management, resource governance, and safe update strategies.

**Key Features:**
- Complete 3-tier architecture (Frontend → Backend → Database)
- Automated TLS certificate provisioning with cert-manager & Let's Encrypt
- Rolling updates with zero downtime (maxUnavailable: 0)
- StatefulSet for database with persistent storage
- Namespace-level resource quotas and limit ranges
- Rollback capability with revision history
- Internal service mesh using ClusterIP services

**Technologies:** Kubernetes, cert-manager, PostgreSQL, Ingress-Nginx, Let's Encrypt

---

### [Project 3 — Network Policy & Zero-Trust Security](./project_3/)
**Focus:** Pod networking, network security, traffic control

Advanced Kubernetes networking demonstrating zero-trust security principles with fine-grained network policies for pod-to-pod communication control.

**Key Features:**
- Zero-trust networking with default deny-all policy
- 3-tier application with network segmentation (Frontend → Backend → Database)
- Label-based traffic control between tiers
- DNS egress filtering with selective allow rules
- Multi-replica deployments with health probes
- Ingress and egress policy enforcement

**Technologies:** Kubernetes NetworkPolicy, Nginx, Redis, http-echo

---

## 🛠️ Technical Skills Demonstrated

- **Container Orchestration:** Deployments, StatefulSets, Services, Ingress
- **Security:** TLS/SSL automation, secrets management, network policies, zero-trust networking
- **High Availability:** Multi-replica deployments, health probes, PodDisruptionBudgets
- **Resource Management:** ResourceQuotas, LimitRanges, requests/limits
- **Operations:** Rolling updates, rollbacks, zero-downtime deployments
- **Networking:** ClusterIP, NodePort, Ingress controllers, NetworkPolicies, service discovery
- **Infrastructure as Code:** Declarative YAML manifests, GitOps-ready

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (v1.19+) — local (minikube, kind, k3s) or cloud (EKS, GKE, AKS)
- `kubectl` CLI configured and connected to your cluster
- (Optional) Ingress controller for external access

### Running Projects

Each project is self-contained with its own README and manifests:

```bash
# Project 1 — Nginx Ingress
kubectl apply -f project_1/namespace.yaml
kubectl apply -f project_1/ -n project-1

# Project 2 — 3-Tier Application
kubectl apply -f project_2/k8s/

# Project 3 — Network Policy
kubectl apply -f project_3/namespace.yaml
kubectl apply -f project_3/
```

Detailed instructions, architecture diagrams, and troubleshooting guides are available in each project's README.

## 📋 Repository Structure

```
devOps_project1/
├── README.md                    # This file
├── project_1/                   # Nginx Ingress demo
│   ├── README.md
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── project_2/                   # 3-tier application
│   ├── README.md
│   └── k8s/
│       ├── namespace.yaml
│       ├── frontend-deployment.yaml
│       ├── frontend-service.yaml
│       ├── backend-deployment.yaml
│       ├── backend-service.yaml
│       ├── postgres-statefulset.yaml
│       ├── postgres-service.yaml
│       ├── postgres-configmap.yaml
│       ├── postgres-secret.yaml
│       ├── ingress.yaml
│       ├── cluster-issuer-staging.yaml
│       ├── resourcequota.yaml
│       └── limitrange.yaml
└── project_3/                   # Network policies
    ├── README.md
    ├── namespace.yaml
    ├── network-policy-default-deny.yaml
    ├── frontend-deployment.yaml
    ├── frontend-service.yaml
    ├── frontend-policy.yaml
    ├── backend-deployment.yaml
    ├── backend-service.yaml
    ├── backend-policy.yaml
    ├── database-deployment.yaml
    ├── database-service.yaml
    └── database-policy.yaml
```

## 🎓 Learning Outcomes

Through these projects, I've gained practical experience in:

1. **Designing cloud-native architectures** — Multi-tier applications with proper service separation
2. **Implementing security best practices** — TLS automation, secrets management, network policies, zero-trust
3. **Ensuring high availability** — Health checks, rolling updates, replica management
4. **Managing resources efficiently** — Quotas, limits, and capacity planning
5. **Operating production workloads** — Monitoring readiness, safe deployments, quick rollbacks
6. **Network security** — Traffic segmentation, ingress/egress control, label-based policies

## 🔧 Tools & Technologies

| Category | Technologies |
|----------|-------------|
| **Orchestration** | Kubernetes, kubectl |
| **Networking** | Ingress-Nginx, NetworkPolicy, ClusterIP, NodePort |
| **Security** | cert-manager, Let's Encrypt, TLS/SSL, Zero-Trust |
| **Databases** | PostgreSQL (StatefulSet), Redis |
| **Web Servers** | Nginx |
| **IaC** | YAML manifests, declarative configuration |

## 📈 Future Enhancements

- [ ] CI/CD pipeline integration (GitHub Actions, Jenkins, ArgoCD)
- [ ] Monitoring stack (Prometheus, Grafana)
- [ ] Centralized logging (ELK/EFK stack)
- [ ] Helm charts for templated deployments
- [ ] Terraform for infrastructure provisioning
- [ ] Service mesh implementation (Istio/Linkerd)
- [ ] Automated testing and validation
- [ ] Multi-cluster deployments

## 🤝 Best Practices Implemented

✅ Infrastructure as Code — All configurations version-controlled  
✅ Declarative manifests — Reproducible deployments  
✅ Resource limits — Prevent resource exhaustion  
✅ Health checks — Automatic failure detection and recovery  
✅ Zero-downtime deployments — Rolling updates with proper strategies  
✅ Security hardening — TLS encryption, secrets management, network policies  
✅ Zero-trust networking — Default deny with explicit allow rules  
✅ Documentation — Comprehensive READMEs with examples  
✅ Namespace isolation — Logical separation of environments  

## 📝 Notes

- All projects are designed to run on standard Kubernetes clusters
- Manifests follow Kubernetes API best practices and conventions
- Each project includes validation commands and troubleshooting tips
- Configurations are production-ready but can be adapted for specific environments

## 📧 Contact

For questions, collaboration, or opportunities, feel free to reach out.

---

**Built with ❤️ for learning, sharing, and demonstrating DevOps excellence.**
