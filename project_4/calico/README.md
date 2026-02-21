# Calico Advanced Implementation

**Focus:** GlobalNetworkPolicy, Zero-Trust, Production Best Practices

A complete 3-tier application demonstrating Calico-specific features with production-grade security and resource management.

## 🎯 Overview

This implementation showcases:
- Standard Kubernetes NetworkPolicy for namespace-level security
- Calico GlobalNetworkPolicy for cluster-wide egress control
- StatefulSet with persistent storage
- Security hardening (non-root, read-only filesystem)
- Resource quotas and limits
- Zero-trust networking

## ✨ Key Features

- **3-Tier Architecture** — Frontend (Nginx) → Backend (API) → Database (Redis)
- **Zero-Trust Networking** — Default deny-all with explicit allow rules
- **GlobalNetworkPolicy** — Cluster-wide egress control
- **Security Hardening** — Non-root users, read-only filesystems, dropped capabilities
- **Resource Management** — Quotas, limits, and requests
- **Persistent Storage** — StatefulSet with PVC for database
- **Health Checks** — Liveness and readiness probes

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│         Global Egress Control (Calico)         │
├─────────────────────────────────────────────────┤
│  Frontend (Nginx:8080)                          │
│    ↓ [NetworkPolicy: Allow port 8080]           │
│  Backend (http-echo:8080)                       │
│    ↓ [NetworkPolicy: Allow port 6379]           │
│  Database (Redis:6379 + PVC)                    │
│    ↓ [DNS allowed on all tiers]                 │
└─────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- Kubernetes cluster (v1.23+)
- Calico CNI installed (optional - works with any CNI)
- `kubectl` CLI configured
- `calicoctl` CLI (for Calico-specific features)

## 🚀 Step-by-Step Deployment

### Step 1: Create Namespace

```bash
kubectl apply -f namespace.yaml

# Verify
kubectl get namespace calico-demo
```

### Step 2: Apply Resource Governance

```bash
# Apply ResourceQuota and LimitRange
kubectl apply -f resourcequota.yaml
kubectl apply -f limitrange.yaml

# Verify
kubectl describe resourcequota -n calico-demo
kubectl describe limitrange -n calico-demo
```

### Step 3: Deploy Database Layer

```bash
# Create secret first
kubectl apply -f database-secret.yaml

# Deploy StatefulSet and Service
kubectl apply -f database-statefulset.yaml
kubectl apply -f database-service.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=database -n calico-demo --timeout=120s

# Verify
kubectl get statefulset -n calico-demo
kubectl get pvc -n calico-demo
```

### Step 4: Deploy Backend Layer

```bash
# Apply ConfigMap and Deployment
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n calico-demo --timeout=120s

# Verify
kubectl get deployment backend -n calico-demo
kubectl get pods -l app=backend -n calico-demo
```

### Step 5: Deploy Frontend Layer

```bash
# Apply ConfigMap and Deployment
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Wait for frontend to be ready
kubectl wait --for=condition=ready pod -l app=frontend -n calico-demo --timeout=120s

# Verify
kubectl get deployment frontend -n calico-demo
kubectl get pods -l app=frontend -n calico-demo
```

### Step 6: Apply Network Policies (Zero-Trust)

```bash
# Apply in order (numbered files)
kubectl apply -f 00-default-deny.yaml
kubectl apply -f 01-frontend-policy.yaml
kubectl apply -f 02-backend-policy.yaml
kubectl apply -f 03-database-policy.yaml

# Verify
kubectl get networkpolicies -n calico-demo
kubectl describe networkpolicy -n calico-demo
```

### Step 7: Apply Calico GlobalNetworkPolicy (Optional)

**Note:** This requires Calico CNI and calicoctl CLI.

```bash
# Check if Calico is installed
kubectl get pods -n calico-system 2>/dev/null

# If Calico is installed, apply global policy
calicoctl apply -f 04-global-egress-policy.yaml

# Verify
calicoctl get globalnetworkpolicy
```

## 📋 Deployment Summary

```bash
# Quick deployment (all at once)
kubectl apply -f namespace.yaml
kubectl apply -f resourcequota.yaml,limitrange.yaml
kubectl apply -f database-secret.yaml,database-statefulset.yaml,database-service.yaml
kubectl apply -f backend-deployment.yaml,backend-service.yaml
kubectl apply -f frontend-configmap.yaml,frontend-deployment.yaml,frontend-service.yaml
kubectl apply -f 00-default-deny.yaml,01-frontend-policy.yaml,02-backend-policy.yaml,03-database-policy.yaml

# Wait for all pods
kubectl wait --for=condition=ready pod --all -n calico-demo --timeout=180s
```

## 🔍 Validation & Testing

### Check Deployment Status

```bash
# View all resources
kubectl get all -n calico-demo

# Check pod details
kubectl get pods -n calico-demo -o wide --show-labels

# Check network policies
kubectl get networkpolicies -n calico-demo

# Check resource usage
kubectl top pods -n calico-demo
```

### Test Network Policies

```bash
# Test 1: Frontend → Backend (should succeed)
kubectl exec -n calico-demo deployment/frontend -- wget -qO- http://backend
# Expected: "Backend API - Calico Demo"

# Test 2: Frontend → Database (should fail - blocked)
kubectl exec -n calico-demo deployment/frontend -- timeout 3 wget -qO- http://database:6379 || echo "✓ Blocked by policy"
# Expected: Timeout

# Test 3: Backend → Database (should succeed)
kubectl exec -n calico-demo deployment/backend -- timeout 3 nc -zv database 6379 2>&1 || echo "Connection test"

# Test 4: Check DNS resolution
kubectl exec -n calico-demo deployment/frontend -- nslookup backend
# Expected: Resolves to backend service IP
```

### Verify Security Hardening

```bash
# Check pods are running as non-root
kubectl exec -n calico-demo deployment/frontend -- id
# Expected: uid=101 (non-root)

# Verify read-only filesystem
kubectl exec -n calico-demo deployment/frontend -- touch /test 2>&1
# Expected: Read-only file system error

# Check dropped capabilities
kubectl get pod -n calico-demo -l app=frontend -o jsonpath='{.items[0].spec.containers[0].securityContext}'
```

### Check Calico-Specific Features (if installed)

```bash
# View global policies
calicoctl get globalnetworkpolicy

# Check policy details
calicoctl get globalnetworkpolicy global-egress-control -o yaml

# View network endpoints
calicoctl get workloadendpoint -n calico-demo
```

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete namespace calico-demo

# Delete global policy (if applied)
calicoctl delete globalnetworkpolicy global-egress-control

# Verify cleanup
kubectl get namespace calico-demo
```

## 🎓 Best Practices Demonstrated

✅ **Zero-Trust Networking** — Default deny-all with explicit allow rules  
✅ **Security Hardening** — Non-root users, read-only filesystems, dropped capabilities  
✅ **Resource Management** — Quotas, limits, and requests on all pods  
✅ **Persistent Storage** — StatefulSet with PVC for stateful workloads  
✅ **Health Checks** — Liveness and readiness probes for all containers  
✅ **Secrets Management** — Kubernetes secrets for sensitive data  
✅ **Service Discovery** — DNS-based service communication  
✅ **Rolling Updates** — Zero-downtime deployment strategy  
✅ **Namespace Isolation** — Logical separation of workloads  
✅ **Network Segmentation** — Tier-based traffic control  

## 📊 Architecture Highlights

### Security Layers
1. **Network Layer** — NetworkPolicy + GlobalNetworkPolicy
2. **Container Layer** — SecurityContext with restrictions
3. **Resource Layer** — ResourceQuota + LimitRange
4. **Data Layer** — Secrets for sensitive information

### Traffic Flow
```
External → Frontend (port 8080)
              ↓ (NetworkPolicy allows)
           Backend (port 8080)
              ↓ (NetworkPolicy allows)
           Database (port 6379)
              ↓ (GlobalNetworkPolicy controls egress)
           External (blocked by default)
```

## 🔗 Resources

- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [NetworkPolicy Best Practices](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [StatefulSet Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

## 💡 Key Takeaways

This implementation demonstrates production-ready Kubernetes deployments with:
- **Defense in depth** — Multiple security layers
- **Least privilege** — Minimal permissions and capabilities
- **Resource efficiency** — Proper limits and requests
- **Operational excellence** — Health checks and rolling updates
- **Network security** — Zero-trust with explicit allow rules
