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

### [Project 4 — Advanced CNI Comparison: Calico vs Cilium](./project_4/)
**Focus:** CNI plugins, L7 policies, eBPF, advanced networking

A comprehensive comparison of Calico and Cilium CNI plugins demonstrating their unique capabilities, advanced features, and production-ready implementations.

**Key Features:**
- **Calico Implementation:** GlobalNetworkPolicy, BGP, host endpoint protection, WireGuard encryption
- **Cilium Implementation:** L7 HTTP policies, eBPF-native networking, Hubble observability
- Side-by-side comparison with identical 3-tier applications
- Production best practices (security hardening, resource management)
- **Complete setup guides:** [Calico Setup Guide](./project_4/calico/SETUP_GUIDE.md) | [Cilium Setup Guide](./project_4/cilium/SETUP_GUIDE.md)
- Performance and feature comparison documentation

**Technologies:** Calico, Cilium, eBPF, BGP, WireGuard, Hubble

---

### [Project 5 — HPA, PDB & Karpenter Autoscaling](./project_5/)
**Focus:** Horizontal Pod Autoscaling, Pod Disruption Budgets, Karpenter node autoscaling

A production-grade 3-tier application with pod-level and node-level autoscaling, disruption protection, and AWS Karpenter integration.

**Key Features:**
- HPA with CPU/memory metrics and scale-up/down policies
- PDB on all tiers guaranteeing minimum availability
- Karpenter NodePool with spot + on-demand instances
- EC2NodeClass with instance type selection and consolidation
- Security hardening (non-root, read-only filesystem)
- Zero-downtime rolling updates

**Technologies:** Kubernetes HPA, PDB, Karpenter, AWS EKS, Redis

---

## 🛠️ Technical Skills Demonstrated

- **Container Orchestration:** Deployments, StatefulSets, Services, Ingress
- **Security:** TLS/SSL automation, secrets management, network policies, zero-trust networking
- **High Availability:** Multi-replica deployments, health probes, PodDisruptionBudgets
- **Resource Management:** ResourceQuotas, LimitRanges, requests/limits
- **Operations:** Rolling updates, rollbacks, zero-downtime deployments
- **Networking:** ClusterIP, NodePort, Ingress controllers, NetworkPolicies, service discovery
- **Advanced Networking:** CNI plugins (Calico, Cilium), L7 policies, eBPF, BGP
- **Autoscaling:** HPA, Karpenter, NodePools, EC2NodeClass
- **Disruption Management:** PodDisruptionBudgets, consolidation policies
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

# Project 4 — CNI Comparison
# Calico: See project_4/calico/SETUP_GUIDE.md for complete installation
cd project_4/calico && ./deploy.sh

# Cilium: See project_4/cilium/SETUP_GUIDE.md for complete installation
cd project_4/cilium && ./deploy.sh

# Project 5 — HPA, PDB & Karpenter
cd project_5 && ./deploy.sh
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
├── project_4/                   # Advanced CNI comparison
    ├── README.md
    ├── COMPARISON.md
    ├── calico/
    │   ├── README.md
    │   ├── SETUP_GUIDE.md
    │   ├── deploy.sh
    │   ├── namespace.yaml
    │   ├── *-deployment.yaml
    │   ├── *-service.yaml
    │   ├── *-policy.yaml
    │   └── global-network-policy.yaml
    └── cilium/
        ├── README.md
        ├── SETUP_GUIDE.md
        ├── deploy.sh
        ├── namespace.yaml
        ├── *-deployment.yaml
        ├── *-service.yaml
        ├── l7-http-policy.yaml
        ├── dns-policy.yaml
        └── grpc-policy.yaml
└── project_5/                   # HPA, PDB & Karpenter
    ├── README.md
    ├── deploy.sh
    ├── namespace.yaml
    ├── frontend-deployment.yaml
    ├── frontend-service.yaml
    ├── backend-deployment.yaml
    ├── backend-service.yaml
    ├── database-statefulset.yaml
    ├── database-service.yaml
    ├── configmap.yaml
    ├── database-secret.yaml
    ├── resourcequota.yaml
    ├── limitrange.yaml
    ├── hpa.yaml
    ├── pdb.yaml
    └── karpenter.yaml
```

## 🎓 Learning Outcomes

Through these projects, I've gained practical experience in:

1. **Designing cloud-native architectures** — Multi-tier applications with proper service separation
2. **Implementing security best practices** — TLS automation, secrets management, network policies, zero-trust
3. **Ensuring high availability** — Health checks, rolling updates, replica management
4. **Managing resources efficiently** — Quotas, limits, and capacity planning
5. **Operating production workloads** — Monitoring readiness, safe deployments, quick rollbacks
6. **Network security** — Traffic segmentation, ingress/egress control, label-based policies
7. **Advanced networking** — CNI plugin comparison, L7 policies, eBPF performance optimization

## 🔧 Tools & Technologies

| Category | Technologies |
|----------|-------------|
| **Orchestration** | Kubernetes, kubectl |
| **Networking** | Ingress-Nginx, NetworkPolicy, ClusterIP, NodePort |
| **CNI Plugins** | Calico, Cilium |
| **Advanced Networking** | eBPF, BGP, WireGuard, Hubble |
| **Security** | cert-manager, Let's Encrypt, TLS/SSL, Zero-Trust |
| **Databases** | PostgreSQL (StatefulSet), Redis |
| **Web Servers** | Nginx |
| **Autoscaling** | HPA, Karpenter, NodePools |
| **IaC** | YAML manifests, declarative configuration |

## 📈 Future Enhancements

- [x] Advanced CNI comparison (Calico vs Cilium)
- [x] HPA, PDB & Karpenter autoscaling
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
✅ L7 policies — Application-layer traffic control (HTTP/gRPC)  
✅ eBPF optimization — High-performance networking  
✅ Documentation — Comprehensive READMEs with examples  
✅ Namespace isolation — Logical separation of environments  
✅ Pod autoscaling — HPA with CPU/memory metrics  
✅ Node autoscaling — Karpenter with spot + on-demand  
✅ Disruption budgets — PDB for safe maintenance  

## 📝 Notes

- All projects are designed to run on standard Kubernetes clusters
- Manifests follow Kubernetes API best practices and conventions
- Each project includes validation commands and troubleshooting tips
- Configurations are production-ready but can be adapted for specific environments

## 📧 Contact

For questions, collaboration, or opportunities, feel free to reach out.

---

**Built with ❤️ for learning, sharing, and demonstrating DevOps excellence.**
