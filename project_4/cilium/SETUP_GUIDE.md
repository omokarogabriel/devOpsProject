# Complete Cilium Setup Guide

A comprehensive step-by-step guide to install and configure Cilium CNI using Helm with L7 policies, Hubble observability, and production best practices.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Install Cilium with Helm](#install-cilium-with-helm)
4. [Verify Installation](#verify-installation)
5. [Deploy Demo Application](#deploy-demo-application)
6. [Test L7 Policies](#test-l7-policies)
7. [Hubble Observability](#hubble-observability)
8. [Troubleshooting](#troubleshooting)
9. [Cleanup](#cleanup)

---

## Prerequisites

### System Requirements
- Kubernetes cluster v1.23+
- Linux kernel 4.19+ (5.4+ recommended for full features)
- `kubectl` CLI configured
- `helm` v3+ installed

### Check Prerequisites
```bash
# Check Kubernetes version
kubectl version --short

# Check kernel version
uname -r

# Check Helm version
helm version --short
```

---

## Installation Methods

This guide uses **Helm** as the primary installation method (recommended for production).

### Why Helm?
- ✅ Version-controlled configuration
- ✅ Easy upgrades and rollbacks
- ✅ Customizable via values.yaml
- ✅ GitOps-ready
- ✅ Production best practice

---

## Install Cilium with Helm

### Method 1: Quick Install (Using Script) - RECOMMENDED

```bash
cd project_4/cilium

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

### Method 2: Manual Install with values.yaml

```bash
# Add Cilium Helm repository
helm repo add cilium https://helm.cilium.io/
helm repo update

# Install using values.yaml
helm install cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --values values.yaml

# Wait for Cilium to be ready
kubectl rollout status daemonset/cilium -n kube-system --timeout=120s
```

### Method 3: Install with Inline Values

```bash
# Basic installation
helm install cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
```

### Customize Installation

Edit `values.yaml` to customize your installation:

```yaml
# Enable/disable features
hubble:
  enabled: true          # Enable Hubble observability
  relay:
    enabled: true        # Enable Hubble Relay
  ui:
    enabled: true        # Enable Hubble UI

# Enable encryption (optional)
encryption:
  enabled: true
  type: wireguard

# Enable metrics (optional)
prometheus:
  enabled: true
```

Then apply:
```bash
helm upgrade cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --values values.yaml
```

---

## Verify Installation

### Check Cilium Pods
```bash
# Check all Cilium components
kubectl get pods -n kube-system -l k8s-app=cilium
kubectl get pods -n kube-system -l app.kubernetes.io/name=hubble-relay

# Check DaemonSet
kubectl get ds -n kube-system cilium

# Check Helm release
helm list -n kube-system
```

### Verify Cilium is Working
```bash
# Create test pods
kubectl run test-1 --image=nginx
kubectl run test-2 --image=nginx

# Wait for pods
kubectl wait --for=condition=ready pod test-1 test-2 --timeout=60s

# Test connectivity
kubectl exec test-1 -- ping -c 3 $(kubectl get pod test-2 -o jsonpath='{.status.podIP}')

# Cleanup
kubectl delete pod test-1 test-2
```

---

## Deploy Demo Application

### Quick Deploy (All at Once)
```bash
cd project_4/cilium
kubectl apply -f namespace.yaml
kubectl apply -f .
kubectl wait --for=condition=ready pod --all -n cilium-demo --timeout=120s
```

### Step-by-Step Deploy

```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Deploy all components
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f database-deployment.yaml
kubectl apply -f database-service.yaml

# 3. Apply network policies
kubectl apply -f l7-http-policy.yaml
kubectl apply -f dns-policy.yaml

# 4. Verify deployment
kubectl get all -n cilium-demo
kubectl get ciliumnetworkpolicies -n cilium-demo
```

---

## Test L7 Policies

### Test Allowed HTTP Methods

```bash
# Test GET (allowed)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- http://backend
# Expected: "Backend API - Cilium L7 Demo"

# Test POST (allowed)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --post-data="test" http://backend
# Expected: Success

# Test HEAD (allowed)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=HEAD http://backend
# Expected: Success
```

### Test Blocked HTTP Methods

```bash
# Test DELETE (blocked by L7 policy)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=DELETE http://backend 2>&1
# Expected: Connection timeout or 403 Forbidden

# Test PUT (blocked by L7 policy)
kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=PUT http://backend 2>&1
# Expected: Connection timeout or 403 Forbidden
```

### Test Network Segmentation

```bash
# Frontend → Database (blocked)
kubectl exec -n cilium-demo deployment/frontend -- timeout 3 wget -qO- http://database:6379 || echo "✓ Blocked"
# Expected: Timeout

# Backend → Database (allowed)
kubectl exec -n cilium-demo deployment/backend -- timeout 3 nc -zv database 6379 2>&1 || echo "Test complete"
# Expected: Connection succeeds
```

---

## Hubble Observability

### Access Hubble UI

```bash
# Port-forward Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80

# Open browser to http://localhost:12000
```

### View Traffic (if Hubble CLI installed)

```bash
# Watch all traffic
kubectl port-forward -n kube-system svc/hubble-relay 4245:80 &
hubble observe --namespace cilium-demo

# Filter by pod
hubble observe --from-pod frontend --namespace cilium-demo

# Filter dropped packets
hubble observe --verdict DROPPED --namespace cilium-demo
```

**Note:** Hubble CLI is optional. The UI provides full observability features.

---

## Troubleshooting

### Check Cilium Status
```bash
# Check pods
kubectl get pods -n kube-system | grep cilium

# Check logs
kubectl logs -n kube-system daemonset/cilium --tail=50
kubectl logs -n kube-system deployment/cilium-operator --tail=50

# Restart Cilium if needed
kubectl rollout restart daemonset/cilium -n kube-system
```

### Hubble Relay Issues

If Hubble Relay shows errors (common DNS timeout issue):

```bash
# Check Hubble Relay status
kubectl get pods -n kube-system -l app.kubernetes.io/name=hubble-relay

# View logs
kubectl logs -n kube-system -l app.kubernetes.io/name=hubble-relay

# Restart Hubble Relay
kubectl rollout restart deployment/hubble-relay -n kube-system

# If issue persists, disable and re-enable Hubble
helm upgrade cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --reuse-values \
  --set hubble.relay.enabled=false

helm upgrade cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --reuse-values \
  --set hubble.relay.enabled=true
```

### Policy Not Working
```bash
# Check if policy is applied
kubectl get ciliumnetworkpolicies -n cilium-demo

# Describe policy
kubectl describe ciliumnetworkpolicy <policy-name> -n cilium-demo

# Check Cilium endpoints
kubectl get cep -n cilium-demo
```

---

## Cleanup

### Remove Demo Application
```bash
kubectl delete namespace cilium-demo
```

### Uninstall Cilium
```bash
# Uninstall via Helm
helm uninstall cilium -n kube-system

# Verify removal
kubectl get pods -n kube-system | grep cilium
```

### Complete Reinstall

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

---

## Quick Reference

### Helm Commands
```bash
# Install
helm install cilium cilium/cilium --version 1.19.0 -n kube-system -f values.yaml

# Upgrade
helm upgrade cilium cilium/cilium --version 1.19.0 -n kube-system -f values.yaml

# Check status
helm status cilium -n kube-system

# Get values
helm get values cilium -n kube-system

# Uninstall
helm uninstall cilium -n kube-system
```

### Useful kubectl Commands
```bash
# Check Cilium pods
kubectl get pods -n kube-system -l k8s-app=cilium

# Check policies
kubectl get ciliumnetworkpolicies -A

# Check endpoints
kubectl get cep -A

# Port-forward Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
```

---

## Resources

- [Cilium Documentation](https://docs.cilium.io/)
- [Cilium Helm Chart](https://github.com/cilium/cilium/tree/main/install/kubernetes/cilium)
- [Hubble Documentation](https://docs.cilium.io/en/stable/observability/hubble/)
- [Cilium Network Policies](https://docs.cilium.io/en/stable/security/policy/)

---

**Built with ❤️ for production-ready Kubernetes networking**
