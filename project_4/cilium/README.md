# Cilium Advanced Implementation

**Focus:** L7 HTTP Policies, eBPF, Production Best Practices

A complete 3-tier application demonstrating Cilium's L7 policy capabilities with HTTP method/path filtering and production-grade security.

## 🎯 Overview

This implementation showcases:
- Cilium L7 HTTP policies (method and path filtering)
- eBPF-native networking
- StatefulSet with persistent storage
- Security hardening (non-root, read-only filesystem)
- Resource quotas and limits
- Zero-trust networking with application-layer control

## ✨ Key Features

- **3-Tier Architecture** — Frontend (Nginx) → Backend (API) → Database (Redis)
- **L7 HTTP Policies** — Control traffic by HTTP method (GET, POST, DELETE)
- **Zero-Trust Networking** — Default deny-all with explicit allow rules
- **eBPF-Native** — Superior performance without iptables
- **Security Hardening** — Non-root users, read-only filesystems, dropped capabilities
- **Resource Management** — Quotas, limits, and requests
- **Persistent Storage** — StatefulSet with PVC for database

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│         Cilium L7 Policy Enforcement             │
├──────────────────────────────────────────────────┤
│  Frontend (Nginx:8080)                           │
│    ↓ [L7: GET, POST allowed]                     │
│  Backend (http-echo:8080)                        │
│    ↓ [L4: TCP 6379 allowed]                      │
│  Database (Redis:6379 + PVC)                     │
│    ↓ [DNS allowed on all tiers]                  │
└──────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- Kubernetes cluster (v1.23+)
- Cilium CNI installed (or standard CNI - policies work with both)
- `kubectl` CLI configured
- (Optional) `cilium` CLI for advanced features

## 🚀 Step-by-Step Deployment

### Step 1: Create Namespace

```bash
kubectl apply -f namespace.yaml

# Verify
kubectl get namespace cilium-demo
```

### Step 2: Apply Resource Governance

```bash
kubectl apply -f resources.yaml

# Verify
kubectl describe resourcequota -n cilium-demo
kubectl describe limitrange -n cilium-demo
```

### Step 3: Deploy Database Layer

```bash
# Create secret and service
kubectl apply -f database.yaml

# Deploy StatefulSet
kubectl apply -f database-statefulset.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=database -n cilium-demo --timeout=120s

# Verify
kubectl get statefulset -n cilium-demo
kubectl get pvc -n cilium-demo
```

### Step 4: Deploy Backend Layer

```bash
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n cilium-demo --timeout=120s

# Verify
kubectl get deployment backend -n cilium-demo
```

### Step 5: Deploy Frontend Layer

```bash
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Wait for frontend to be ready
kubectl wait --for=condition=ready pod -l app=frontend -n cilium-demo --timeout=120s

# Verify
kubectl get deployment frontend -n cilium-demo
```

### Step 6: Apply Cilium L7 Network Policies

```bash
# Apply in order
kubectl apply -f 00-default-deny.yaml
kubectl apply -f 01-frontend-policy.yaml
kubectl apply -f 02-backend-policy.yaml
kubectl apply -f 03-database-policy.yaml

# Verify
kubectl get ciliumnetworkpolicies -n cilium-demo
kubectl describe ciliumnetworkpolicy frontend-policy -n cilium-demo
```

## 📋 Quick Deployment

```bash
# Automated deployment
./deploy.sh

# Or all at once
kubectl apply -f namespace.yaml
kubectl apply -f resources.yaml
kubectl apply -f database.yaml,database-statefulset.yaml
kubectl apply -f backend-deployment.yaml,backend-service.yaml
kubectl apply -f frontend-configmap.yaml,frontend-deployment.yaml,frontend-service.yaml
kubectl apply -f 00-default-deny.yaml,01-frontend-policy.yaml,02-backend-policy.yaml,03-database-policy.yaml

# Wait for all pods
kubectl wait --for=condition=ready pod --all -n cilium-demo --timeout=180s
```

## 🔍 Validation & Testing

### Check Deployment Status

```bash
# View all resources
kubectl get all -n cilium-demo

# Check pod details
kubectl get pods -n cilium-demo -o wide --show-labels

# Check Cilium network policies
kubectl get ciliumnetworkpolicies -n cilium-demo

# Check resource usage
kubectl top pods -n cilium-demo
```

### Test L7 HTTP Policies

```bash
# Test 1: GET request (allowed by L7 policy)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- http://backend
# Expected: "Backend API - Cilium L7 Demo"

# Test 2: POST request (allowed by L7 policy)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --post-data="test" http://backend
# Expected: Success

# Test 3: DELETE request (blocked by L7 policy)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=DELETE http://backend 2>&1 || echo "✓ Blocked by L7 policy"
# Expected: Blocked (DELETE not in allowed methods)

# Test 4: Frontend → Database (blocked by L4 policy)
kubectl exec -n cilium-demo deployment/frontend -- timeout 3 wget -qO- http://database:6379 || echo "✓ Blocked by policy"
# Expected: Timeout
```

### Verify Security Hardening

```bash
# Check pods are running as non-root
kubectl exec -n cilium-demo deployment/frontend -- id
# Expected: uid=101 (non-root)

# Verify read-only filesystem
kubectl exec -n cilium-demo deployment/frontend -- touch /test 2>&1
# Expected: Read-only file system error
```

### Check Cilium-Specific Features (if Cilium CNI installed)

```bash
# Check Cilium status
cilium status

# View Cilium endpoints
cilium endpoint list

# Check policy enforcement
cilium policy get

# View network flows (if Hubble enabled)
hubble observe --namespace cilium-demo

# Filter by pod
hubble observe --from-pod frontend --namespace cilium-demo

# Filter by HTTP method
hubble observe --http-method GET --namespace cilium-demo
```

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete namespace cilium-demo

# Verify cleanup
kubectl get namespace cilium-demo
```

## 🎓 Best Practices Demonstrated

✅ **L7 HTTP Policies** — Method-level access control (GET, POST allowed; DELETE blocked)  
✅ **Zero-Trust Networking** — Default deny-all with explicit allow rules  
✅ **Security Hardening** — Non-root users, read-only filesystems, dropped capabilities  
✅ **Resource Management** — Quotas, limits, and requests on all pods  
✅ **Persistent Storage** — StatefulSet with PVC for stateful workloads  
✅ **Health Checks** — Liveness and readiness probes for all containers  
✅ **Secrets Management** — Kubernetes secrets for sensitive data  
✅ **eBPF-Native** — Superior performance without iptables overhead  
✅ **Rolling Updates** — Zero-downtime deployment strategy  
✅ **DNS Policies** — DNS-aware traffic control  

## 📊 L7 Policy Highlights

### HTTP Method Filtering
```yaml
rules:
  http:
  - method: "GET"     # ✅ Allowed
  - method: "POST"    # ✅ Allowed
  # DELETE not listed  # ❌ Blocked
```

### Path-Based Filtering (Example)
```yaml
rules:
  http:
  - method: "GET"
    path: "/api/.*"    # Only /api/* paths
  - method: "POST"
    path: "/api/users" # Specific endpoint
```

### Traffic Flow with L7
```
Frontend → Backend
  GET /     ✅ Allowed (L7 rule)
  POST /    ✅ Allowed (L7 rule)
  DELETE /  ❌ Blocked (not in L7 rules)
  
Frontend → Database
  TCP 6379  ❌ Blocked (no L4 rule)
```

## 🔗 Resources

- [Cilium Documentation](https://docs.cilium.io/)
- [L7 Policy Examples](https://docs.cilium.io/en/stable/security/policy/language/#layer-7-examples)
- [Hubble Observability](https://docs.cilium.io/en/stable/observability/hubble/)
- [eBPF Introduction](https://ebpf.io/)

## 💡 Key Takeaways

This implementation demonstrates:
- **Application-layer security** — Control traffic by HTTP method and path
- **eBPF performance** — Native kernel networking without iptables
- **Production-ready** — Security hardening, resource limits, health checks
- **Zero-trust** — Default deny with explicit L7 allow rules
- **Observability-ready** — Compatible with Hubble for network visibility
