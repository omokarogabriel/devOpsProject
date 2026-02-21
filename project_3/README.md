# Project 3 — Network Policy & Zero-Trust Security

**Focus:** Pod networking, network security, traffic control

A demonstration of advanced Kubernetes networking using native NetworkPolicy for pod-to-pod communication control and network policy enforcement.

## 🎯 Overview

This project showcases network segmentation and security controls using Kubernetes native NetworkPolicy resources. It demonstrates how to implement zero-trust networking principles with fine-grained traffic policies.

## ✨ Key Features

- Zero-trust networking with default deny-all policy
- 3-tier application with network segmentation (Frontend → Backend → Database)
- Label-based traffic control between tiers
- DNS egress allowed for service discovery
- Multi-replica deployments with health probes
- Resource limits and requests for stability

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│              Default Deny All                    │
├──────────────────────────────────────────────────┤
│  Frontend (Nginx)                                │
│    ↓ [Allow: port 80]                            │
│  Backend (API)                                   │
│    ↓ [Allow: port 5678]                          │
│  Database (Redis)                                │
│    ↓ [Allow: port 6379]                          │
│  [DNS egress allowed on all tiers]               │
└──────────────────────────────────────────────────┘
```

**Traffic Flow:**
- Frontend accepts traffic from any pod in namespace
- Frontend can only communicate with Backend
- Backend accepts traffic only from Frontend
- Backend can only communicate with Database
- Database accepts traffic only from Backend
- All tiers can perform DNS lookups

## 🚀 Deployment

```bash
# Apply all manifests
kubectl apply -f project_3/

# Verify deployments
kubectl get all -n project-3

# Check network policies
kubectl get networkpolicies -n project-3

# View policy details
kubectl describe networkpolicy frontend-policy -n project-3
```

## 🧹 Cleanup

```bash
# Delete entire namespace (removes all resources including network policies)
kubectl delete namespace project-3

# Or delete specific resources while keeping namespace
kubectl delete all,networkpolicies --all -n project-3
```

## 🔍 Validation

```bash
# Test 1: Frontend → Backend (should succeed)
kubectl exec -n project-3 deployment/frontend -- wget -qO- http://backend:5678
# Expected: "Backend API Response"

# Test 2: Frontend → Database (should fail - blocked by policy)
kubectl exec -n project-3 deployment/frontend -- timeout 3 wget -qO- http://database:6379 || echo "✓ Blocked by network policy"
# Expected: Timeout (connection blocked)

# Test 3: Backend → Database (should succeed)
kubectl exec -n project-3 deployment/database -- redis-cli -h database ping
# Expected: "PONG"

# View pod IPs and labels
kubectl get pods -n project-3 -o wide --show-labels

# Check network policy enforcement
kubectl describe networkpolicy -n project-3
```

## 📚 Technologies

- **Kubernetes NetworkPolicy** — Native traffic control
- **Nginx** — Frontend web server
- **Redis** — Database layer
- **http-echo** — Backend API service

## 📋 Manifests

- `namespace.yaml` — Project namespace
- `network-policy-default-deny.yaml` — Zero-trust baseline
- `frontend-deployment.yaml` + `frontend-service.yaml` + `frontend-policy.yaml`
- `backend-deployment.yaml` + `backend-service.yaml` + `backend-policy.yaml`
- `database-deployment.yaml` + `database-service.yaml` + `database-policy.yaml`

## 🎓 Learning Outcomes

- Implementing zero-trust network security
- Label-based traffic segmentation
- Tier-to-tier communication control
- Egress filtering with DNS exceptions
