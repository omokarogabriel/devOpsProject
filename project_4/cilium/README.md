# Cilium CNI with L7 Policies

Production-ready Cilium CNI deployment with eBPF-native networking, L7 HTTP policies, and Hubble observability.

## 📁 Project Structure

```
cilium/
├── README.md                    # This file
├── SETUP_GUIDE.md              # Complete installation guide
├── values.yaml                  # Helm configuration
├── helm-install.sh             # Automated installation script
├── namespace.yaml              # Demo namespace
├── frontend-deployment.yaml    # Frontend app
├── frontend-service.yaml
├── backend-deployment.yaml     # Backend API
├── backend-service.yaml
├── database-deployment.yaml    # Redis database
├── database-service.yaml
├── l7-http-policy.yaml        # L7 HTTP method policies
└── dns-policy.yaml            # DNS egress policies
```

## 🚀 Quick Start

### 1. Install Cilium

```bash
# Using the installation script
./helm-install.sh

# Wait for Cilium to be ready
kubectl rollout status daemonset/cilium -n kube-system --timeout=120s

# Verify Cilium is running
kubectl get pods -n kube-system | grep cilium
```

### 2. Deploy Demo Application

```bash
# Deploy all components
./deploy.sh
```

### 3. Access Hubble UI

```bash
# Port-forward Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80

# Open browser to http://localhost:12000
```

## 🔍 Key Features

### eBPF-Native Networking
- High-performance packet processing
- Kernel-level network visibility
- Minimal overhead compared to iptables

### L7 HTTP Policies
- Method-based access control (GET, POST, PUT, DELETE)
- Path-based routing rules
- Header inspection and filtering

### Hubble Observability
- Real-time traffic visualization
- Service dependency mapping
- Network policy troubleshooting

### DNS-Based Egress Control
- FQDN-based policies
- Selective external access
- DNS query monitoring

## 📊 Architecture

```
┌─────────────┐
│   Ingress   │
└──────┬──────┘
       │
┌──────▼──────────┐
│    Frontend     │  (Nginx)
│  L7 Policy: ✓   │
└──────┬──────────┘
       │ HTTP GET/POST only
┌──────▼──────────┐
│     Backend     │  (HTTP Echo)
│  L7 Policy: ✓   │
└──────┬──────────┘
       │ TCP 6379 only
┌──────▼──────────┐
│    Database     │  (Redis)
│  L7 Policy: ✓   │
└─────────────────┘
```

## 🧪 Testing L7 Policies

### Test Allowed HTTP Methods

```bash
# GET request (allowed)
kubectl exec -n cilium-demo deployment/frontend -- \
  wget -qO- http://backend

# POST request (allowed)
kubectl exec -n cilium-demo deployment/frontend -- \
  wget -qO- --post-data="test" http://backend
```

### Test Blocked HTTP Methods

```bash
# DELETE request (blocked)
kubectl exec -n cilium-demo deployment/frontend -- \
  wget -qO- --method=DELETE http://backend

# PUT request (blocked)
kubectl exec -n cilium-demo deployment/frontend -- \
  wget -qO- --method=PUT http://backend
```

### Test Network Segmentation

```bash
# Frontend → Database (blocked)
kubectl exec -n cilium-demo deployment/frontend -- \
  timeout 3 wget -qO- http://database:6379 || echo "✓ Blocked"

# Backend → Database (allowed)
kubectl exec -n cilium-demo deployment/backend -- \
  timeout 3 nc -zv database 6379
```

## 📈 Hubble Observability

### Access Hubble UI

```bash
# Port-forward Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80

# Open browser to http://localhost:12000
```

### Features
- Service map visualization
- Real-time traffic flows
- HTTP request/response inspection
- DNS query monitoring
- Policy enforcement visualization

## 🛠️ Configuration

### Customize Helm Values

Edit `values.yaml` to enable/disable features:

```yaml
# Enable Hubble
hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true

# Enable encryption (optional)
encryption:
  enabled: true
  type: wireguard

# Enable metrics (optional)
prometheus:
  enabled: true
```

Apply changes:
```bash
helm upgrade cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --values values.yaml
```

## 🔧 Troubleshooting

### Check Cilium Status
```bash
kubectl get pods -n kube-system | grep cilium
kubectl logs -n kube-system daemonset/cilium --tail=50
```

### Restart Cilium
```bash
kubectl rollout restart daemonset/cilium -n kube-system
```

### Check Network Policies
```bash
kubectl get ciliumnetworkpolicies -n cilium-demo
kubectl describe ciliumnetworkpolicy <policy-name> -n cilium-demo
```

## 🧹 Cleanup

```bash
# Remove demo application
kubectl delete namespace cilium-demo

# Uninstall Cilium
helm uninstall cilium -n kube-system
```

## 🔄 Complete Reinstall

```bash
# 1. Install Cilium with Helm (includes Hubble UI)
./helm-install.sh

# 2. Wait for Cilium to be ready
kubectl rollout status daemonset/cilium -n kube-system --timeout=120s

# 3. Verify Cilium is running
kubectl get pods -n kube-system | grep cilium

# 4. Deploy demo application
./deploy.sh

# 5. Access Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
# Open browser to http://localhost:12000
```

## 📚 Documentation

- [Complete Setup Guide](./SETUP_GUIDE.md) - Detailed installation and configuration
- [Cilium Official Docs](https://docs.cilium.io/)
- [Hubble Documentation](https://docs.cilium.io/en/stable/observability/hubble/)

## 🎯 Use Cases

- **Zero-trust networking** - Default deny with explicit allow rules
- **API security** - L7 HTTP method and path-based policies
- **Compliance** - Network traffic auditing and monitoring
- **Microservices** - Service-to-service communication control
- **Multi-tenancy** - Namespace-level network isolation

---

**Built with ❤️ for production-ready Kubernetes networking**
