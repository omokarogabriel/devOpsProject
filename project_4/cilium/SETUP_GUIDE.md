# Complete Cilium Setup Guide

A comprehensive step-by-step guide to install and configure Cilium CNI with L7 policies, Hubble observability, and production best practices.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install Cilium CLI](#install-cilium-cli)
3. [Install Cilium CNI](#install-cilium-cni)
4. [Verify Installation](#verify-installation)
5. [Install Hubble Observability](#install-hubble-observability)
6. [Deploy Demo Application](#deploy-demo-application)
7. [Test L7 Policies](#test-l7-policies)
8. [Hubble Monitoring](#hubble-monitoring)
9. [Advanced Features](#advanced-features)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- Kubernetes cluster v1.23+
- Linux kernel 4.19+ (5.4+ recommended for full features)
- CNI plugin not installed (or ability to replace existing CNI)
- `kubectl` CLI configured

### Check Kernel Version
```bash
uname -r
# Should be >= 4.19
```

### Check Existing CNI
```bash
kubectl get pods -n kube-system | grep -E 'calico|flannel|weave|cilium'
# If you see another CNI, you'll need to remove it first
```

---

## Install Cilium CLI

### Linux (amd64)
```bash
# Get latest version
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64

# Download
curl -L --fail --remote-name-all \
  https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Verify checksum
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

# Extract and install
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin

# Cleanup
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Verify
cilium version --client
```

### macOS
```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64

curl -L --fail --remote-name-all \
  https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}

shasum -a 256 -c cilium-darwin-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-darwin-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium version --client
```

---

## Install Cilium CNI

### Option 1: Quick Install (Recommended for Testing)

```bash
# Install Cilium with default settings
cilium install --version 1.15.0

# Wait for installation to complete
cilium status --wait
```

### Option 2: Install with Hubble Enabled

```bash
# Install Cilium with Hubble observability
cilium install \
  --version 1.15.0 \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

# Wait for installation
cilium status --wait
```

### Option 3: Install with Advanced Features

```bash
# Install with encryption, Hubble, and metrics
cilium install \
  --version 1.15.0 \
  --set encryption.enabled=true \
  --set encryption.type=wireguard \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true

cilium status --wait
```

### Option 4: Install CRDs Only (For Existing CNI)

```bash
# If you want to use Cilium policies without replacing your CNI
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/main/pkg/k8s/apis/cilium.io/client/crds/v2/ciliumnetworkpolicies.yaml
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/main/pkg/k8s/apis/cilium.io/client/crds/v2/ciliumclusterwidenetworkpolicies.yaml
```

---

## Verify Installation

### Check Cilium Status
```bash
# Overall status
cilium status

# Detailed status
cilium status --wait --verbose

# Check pods
kubectl get pods -n kube-system -l k8s-app=cilium

# Check DaemonSet
kubectl get ds -n kube-system cilium
```

### Run Connectivity Test
```bash
# Comprehensive connectivity test (takes 5-10 minutes)
cilium connectivity test

# Quick test
cilium connectivity test --test pod-to-pod
```

### Verify eBPF Maps
```bash
# List eBPF endpoints
cilium bpf endpoint list

# Check policy enforcement
cilium policy get
```

---

## Install Hubble Observability

### Install Hubble CLI

```bash
# Linux
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64

curl -L --fail --remote-name-all \
  https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

hubble version
```

### Enable Hubble (if not already enabled)

```bash
# Enable Hubble relay and UI
cilium hubble enable --ui

# Verify Hubble is running
kubectl get pods -n kube-system -l k8s-app=hubble-relay
kubectl get pods -n kube-system -l k8s-app=hubble-ui
```

### Port-Forward Hubble

```bash
# Port-forward Hubble relay for CLI
cilium hubble port-forward &

# Test Hubble CLI
hubble status

# Access Hubble UI (opens browser)
cilium hubble ui
# Navigate to http://localhost:12000
```

---

## Deploy Demo Application

### Step 1: Create Namespace
```bash
kubectl apply -f namespace.yaml
```

### Step 2: Apply Resource Governance
```bash
kubectl apply -f resources.yaml
```

### Step 3: Deploy Database
```bash
kubectl apply -f database.yaml
kubectl apply -f database-statefulset.yaml
kubectl wait --for=condition=ready pod -l app=database -n cilium-demo --timeout=120s
```

### Step 4: Deploy Backend
```bash
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl wait --for=condition=ready pod -l app=backend -n cilium-demo --timeout=120s
```

### Step 5: Deploy Frontend
```bash
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl wait --for=condition=ready pod -l app=frontend -n cilium-demo --timeout=120s
```

### Step 6: Apply L7 Network Policies
```bash
kubectl apply -f 00-default-deny.yaml
kubectl apply -f 01-frontend-policy.yaml
kubectl apply -f 02-backend-policy.yaml
kubectl apply -f 03-database-policy.yaml
```

### Verify Deployment
```bash
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

## Hubble Monitoring

### View Live Traffic Flows

```bash
# Watch all traffic in namespace
hubble observe --namespace cilium-demo

# Filter by pod
hubble observe --from-pod frontend --namespace cilium-demo

# Filter by HTTP method
hubble observe --http-method GET --namespace cilium-demo

# Filter by verdict (dropped packets)
hubble observe --verdict DROPPED --namespace cilium-demo

# Follow live traffic
hubble observe --follow --namespace cilium-demo
```

### View Service Dependencies

```bash
# JSON output for analysis
hubble observe --namespace cilium-demo -o json | jq

# Compact output
hubble observe --namespace cilium-demo -o compact

# Dictionary output
hubble observe --namespace cilium-demo -o dict
```

### Hubble UI

```bash
# Access Hubble UI
cilium hubble ui
# Opens http://localhost:12000

# Features:
# - Service map visualization
# - Real-time traffic flows
# - HTTP request/response inspection
# - DNS query monitoring
# - Policy enforcement visualization
```

---

## Advanced Features

### Enable WireGuard Encryption

```bash
# Enable transparent encryption
cilium config set enable-wireguard true

# Verify encryption
cilium status | grep Encryption

# Check WireGuard status
cilium encrypt status
```

### Enable BGP Control Plane

```bash
# Install with BGP
cilium install --set bgpControlPlane.enabled=true

# Configure BGP peer
kubectl apply -f - <<EOF
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPPeeringPolicy
metadata:
  name: bgp-peering
spec:
  nodeSelector:
    matchLabels:
      bgp: enabled
  virtualRouters:
  - localASN: 64512
    exportPodCIDR: true
    neighbors:
    - peerAddress: 192.168.1.1/32
      peerASN: 64513
EOF
```

### Cluster Mesh (Multi-Cluster)

```bash
# Enable cluster mesh on cluster 1
cilium clustermesh enable --context cluster1

# Enable cluster mesh on cluster 2
cilium clustermesh enable --context cluster2

# Connect clusters
cilium clustermesh connect --context cluster1 --destination-context cluster2

# Verify
cilium clustermesh status --context cluster1
```

### Prometheus Metrics

```bash
# Enable metrics
cilium config set prometheus-serve-addr :9090

# Check metrics endpoint
kubectl port-forward -n kube-system ds/cilium 9090:9090 &
curl http://localhost:9090/metrics
```

---

## Troubleshooting

### Check Cilium Logs

```bash
# View Cilium agent logs
kubectl logs -n kube-system ds/cilium --tail=100 -f

# View Cilium operator logs
kubectl logs -n kube-system deployment/cilium-operator --tail=100 -f

# View Hubble relay logs
kubectl logs -n kube-system deployment/hubble-relay --tail=100 -f
```

### Debug Policy Issues

```bash
# Check policy enforcement
cilium policy get

# View endpoint details
cilium endpoint list

# Check specific endpoint
cilium endpoint get <endpoint-id>

# View policy trace
cilium monitor --type policy-verdict
```

### Common Issues

#### Issue: Pods can't communicate
```bash
# Check Cilium status
cilium status

# Run connectivity test
cilium connectivity test

# Check eBPF programs
cilium bpf endpoint list

# Restart Cilium
kubectl rollout restart ds/cilium -n kube-system
```

#### Issue: L7 policies not working
```bash
# Verify Envoy proxy is running
kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[*].spec.containers[*].name}'

# Check policy syntax
kubectl describe ciliumnetworkpolicy <policy-name> -n <namespace>

# View denied requests
hubble observe --verdict DROPPED --namespace <namespace>
```

#### Issue: Hubble not showing traffic
```bash
# Check Hubble relay
kubectl get pods -n kube-system -l k8s-app=hubble-relay

# Restart Hubble relay
kubectl rollout restart deployment/hubble-relay -n kube-system

# Re-enable Hubble
cilium hubble disable
cilium hubble enable --ui
```

---

## Cleanup

### Remove Demo Application
```bash
kubectl delete namespace cilium-demo
```

### Uninstall Cilium
```bash
# Uninstall Cilium CNI
cilium uninstall

# Verify removal
kubectl get pods -n kube-system | grep cilium
```

### Remove Cilium CLI
```bash
sudo rm /usr/local/bin/cilium
sudo rm /usr/local/bin/hubble
```

---

## Best Practices

✅ **Use L7 policies** for HTTP/gRPC services  
✅ **Enable Hubble** for observability  
✅ **Enable encryption** for sensitive workloads  
✅ **Monitor with Prometheus** for production  
✅ **Use DNS policies** for external service control  
✅ **Test policies** before production deployment  
✅ **Keep Cilium updated** for security patches  
✅ **Use resource limits** on Cilium pods  
✅ **Enable audit logs** for compliance  
✅ **Document policies** for team knowledge  

---

## Resources

- [Cilium Documentation](https://docs.cilium.io/)
- [Cilium GitHub](https://github.com/cilium/cilium)
- [Hubble Documentation](https://docs.cilium.io/en/stable/observability/hubble/)
- [eBPF Introduction](https://ebpf.io/)
- [Cilium Slack Community](https://cilium.io/slack)

---

**Built with ❤️ for production-ready Kubernetes networking**
