# Complete Calico Setup Guide

A comprehensive step-by-step guide to install and configure Calico CNI with GlobalNetworkPolicy, BGP, and production best practices.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install Calico CNI](#install-calico-cni)
3. [Install calicoctl CLI](#install-calicoctl-cli)
4. [Verify Installation](#verify-installation)
5. [Deploy Demo Application](#deploy-demo-application)
6. [Test Network Policies](#test-network-policies)
7. [Advanced Features](#advanced-features)
8. [Monitoring & Observability](#monitoring--observability)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

---

## Prerequisites

### System Requirements
- Kubernetes cluster v1.19+
- Linux kernel 3.10+ (4.19+ for eBPF mode)
- CNI plugin not installed (or ability to replace existing CNI)
- `kubectl` CLI configured

### Check Existing CNI
```bash
kubectl get pods -n kube-system | grep -E 'calico|flannel|weave|cilium'
# If you see another CNI, you'll need to remove it first
```

### Check Kubernetes Version
```bash
kubectl version --short
# Should be >= v1.19
```

---

## Install Calico CNI

### Option 1: Operator-Based Installation (Recommended)

```bash
# Install Tigera Calico operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# Wait for operator to be ready
kubectl wait --for=condition=ready pod -l k8s-app=tigera-operator -n tigera-operator --timeout=120s

# Install Calico custom resources
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

# Wait for Calico to be ready
kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n calico-system --timeout=300s
```

### Option 2: Manifest-Based Installation

```bash
# Install Calico with default settings
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# Wait for Calico to be ready
kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=300s
```

### Option 3: Install with eBPF Dataplane

```bash
# Install operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# Create custom resources with eBPF enabled
kubectl apply -f - <<EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    bgp: Enabled
    ipPools:
    - blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: None
      natOutgoing: Enabled
      nodeSelector: all()
    linuxDataplane: BPF
  flexVolumePath: /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
EOF
```

### Option 4: Install with WireGuard Encryption

```bash
# Install operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# Create custom resources with encryption
kubectl apply -f - <<EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    bgp: Enabled
    ipPools:
    - blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: WireGuard
      natOutgoing: Enabled
      nodeSelector: all()
EOF
```

---

## Install calicoctl CLI

### Linux (amd64)
```bash
# Download calicoctl
curl -L https://github.com/projectcalico/calico/releases/download/v3.27.0/calicoctl-linux-amd64 -o calicoctl

# Make executable
chmod +x calicoctl

# Move to PATH
sudo mv calicoctl /usr/local/bin/

# Verify
calicoctl version
```

### macOS
```bash
# Download calicoctl
curl -L https://github.com/projectcalico/calico/releases/download/v3.27.0/calicoctl-darwin-amd64 -o calicoctl

# Make executable
chmod +x calicoctl

# Move to PATH
sudo mv calicoctl /usr/local/bin/

# Verify
calicoctl version
```

### Configure calicoctl

```bash
# Create config directory
mkdir -p ~/.kube

# Configure calicoctl to use kubectl config
export DATASTORE_TYPE=kubernetes
export KUBECONFIG=~/.kube/config

# Or create calicoctl config file
cat > /etc/calico/calicoctl.cfg <<EOF
apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "kubernetes"
  kubeconfig: "/root/.kube/config"
EOF
```

---

## Verify Installation

### Check Calico Pods

```bash
# Check Calico system pods (operator-based)
kubectl get pods -n calico-system

# Check Calico pods (manifest-based)
kubectl get pods -n kube-system -l k8s-app=calico-node

# Check Calico API server
kubectl get pods -n calico-apiserver
```

### Check Node Status

```bash
# Check node status
calicoctl node status

# Expected output:
# Calico process is running.
# IPv4 BGP status
# +--------------+-------------------+-------+----------+-------------+
# | PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
# +--------------+-------------------+-------+----------+-------------+
```

### Verify Network Configuration

```bash
# Check IP pools
calicoctl get ippool -o wide

# Check BGP configuration
calicoctl get bgpconfig default -o yaml

# Check Felix configuration
calicoctl get felixconfiguration default -o yaml
```

### Run Connectivity Test

```bash
# Create test pods
kubectl run test-1 --image=busybox --command -- sleep 3600
kubectl run test-2 --image=busybox --command -- sleep 3600

# Wait for pods
kubectl wait --for=condition=ready pod test-1 test-2 --timeout=60s

# Test connectivity
kubectl exec test-1 -- ping -c 3 $(kubectl get pod test-2 -o jsonpath='{.status.podIP}')

# Cleanup
kubectl delete pod test-1 test-2
```

---

## Deploy Demo Application

### Quick Deployment

```bash
cd project_4/calico

# Run automated deployment
./deploy.sh
```

### Manual Step-by-Step Deployment

#### Step 1: Create Namespace
```bash
kubectl apply -f namespace.yaml
```

#### Step 2: Apply Resource Governance
```bash
kubectl apply -f resourcequota.yaml
kubectl apply -f limitrange.yaml
```

#### Step 3: Deploy Database
```bash
kubectl apply -f database-secret.yaml
kubectl apply -f database-statefulset.yaml
kubectl apply -f database-service.yaml
kubectl wait --for=condition=ready pod -l app=database -n calico-demo --timeout=120s
```

#### Step 4: Deploy Backend
```bash
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl wait --for=condition=ready pod -l app=backend -n calico-demo --timeout=120s
```

#### Step 5: Deploy Frontend
```bash
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl wait --for=condition=ready pod -l app=frontend -n calico-demo --timeout=120s
```

#### Step 6: Apply Network Policies
```bash
kubectl apply -f 00-default-deny.yaml
kubectl apply -f 01-frontend-policy.yaml
kubectl apply -f 02-backend-policy.yaml
kubectl apply -f 03-database-policy.yaml
```

#### Step 7: Apply GlobalNetworkPolicy (Optional)
```bash
calicoctl apply -f 04-global-egress-policy.yaml
```

### Verify Deployment
```bash
kubectl get all -n calico-demo
kubectl get networkpolicies -n calico-demo
calicoctl get globalnetworkpolicy
```

---

## Test Network Policies

### Test Allowed Traffic

```bash
# Frontend → Backend (allowed)
kubectl exec -n calico-demo deployment/frontend -- wget -qO- http://backend
# Expected: "Backend API - Calico Demo"

# Check DNS resolution
kubectl exec -n calico-demo deployment/frontend -- nslookup backend
# Expected: Resolves to backend service IP
```

### Test Blocked Traffic

```bash
# Frontend → Database (blocked)
kubectl exec -n calico-demo deployment/frontend -- timeout 3 wget -qO- http://database:6379 || echo "✓ Blocked by policy"
# Expected: Timeout

# External egress (blocked by GlobalNetworkPolicy)
kubectl exec -n calico-demo deployment/frontend -- timeout 3 wget -qO- http://google.com || echo "✓ Blocked by global policy"
# Expected: Timeout
```

### Verify Security Hardening

```bash
# Check non-root user
kubectl exec -n calico-demo deployment/frontend -- id
# Expected: uid=101 (non-root)

# Check read-only filesystem
kubectl exec -n calico-demo deployment/frontend -- touch /test 2>&1
# Expected: Read-only file system error
```

---

## Advanced Features

### GlobalNetworkPolicy

```bash
# Create cluster-wide egress policy
calicoctl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: deny-external-egress
spec:
  selector: projectcalico.org/namespace != "kube-system"
  types:
  - Egress
  egress:
  # Allow DNS
  - action: Allow
    protocol: UDP
    destination:
      selector: k8s-app == "kube-dns"
      ports:
      - 53
  # Allow internal cluster
  - action: Allow
    destination:
      nets:
      - 10.244.0.0/16  # Pod CIDR
      - 10.96.0.0/12   # Service CIDR
  # Deny all other egress
  - action: Deny
EOF

# Verify
calicoctl get globalnetworkpolicy -o wide
```

### Host Endpoint Protection

```bash
# Protect Kubernetes nodes
calicoctl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: HostEndpoint
metadata:
  name: node-1-eth0
  labels:
    role: worker
spec:
  interfaceName: eth0
  node: node-1
  expectedIPs:
  - 192.168.1.10
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: host-protection
spec:
  selector: role == "worker"
  types:
  - Ingress
  ingress:
  # Allow SSH
  - action: Allow
    protocol: TCP
    destination:
      ports:
      - 22
  # Allow Kubernetes API
  - action: Allow
    protocol: TCP
    destination:
      ports:
      - 6443
  # Allow kubelet
  - action: Allow
    protocol: TCP
    destination:
      ports:
      - 10250
EOF
```

### BGP Configuration

```bash
# Enable BGP peering
calicoctl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: true
  asNumber: 64512
---
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: rack1-tor
spec:
  peerIP: 192.168.1.1
  asNumber: 64513
  nodeSelector: rack == "rack-1"
EOF

# Check BGP peers
calicoctl node status
```

### IP Pool Management

```bash
# Create custom IP pool
calicoctl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: production-pool
spec:
  cidr: 10.100.0.0/16
  blockSize: 26
  ipipMode: Never
  natOutgoing: true
  nodeSelector: environment == "production"
EOF

# View IP pools
calicoctl get ippool -o wide
```

### WireGuard Encryption

```bash
# Enable WireGuard on all nodes
calicoctl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'

# Verify encryption
calicoctl node status

# Check WireGuard interface
kubectl exec -n calico-system ds/calico-node -- wg show
```

### eBPF Dataplane

```bash
# Switch to eBPF dataplane
calicoctl patch felixconfiguration default --type='merge' -p '{"spec":{"bpfEnabled":true}}'

# Disable kube-proxy
kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'

# Verify eBPF mode
calicoctl get felixconfiguration default -o yaml | grep bpfEnabled
```

---

## Monitoring & Observability

### Prometheus Metrics

```bash
# Enable Prometheus metrics
calicoctl patch felixconfiguration default --type='merge' -p '{"spec":{"prometheusMetricsEnabled":true}}'

# Access metrics
kubectl port-forward -n calico-system ds/calico-node 9091:9091 &
curl http://localhost:9091/metrics
```

### Flow Logs

```bash
# Enable flow logs
calicoctl patch felixconfiguration default --type='merge' -p '{"spec":{"flowLogsEnableHostEndpoint":true,"flowLogsFileEnabled":true}}'

# View flow logs
kubectl logs -n calico-system ds/calico-node -c calico-node | grep "Flow log"
```

### Policy Audit Logs

```bash
# Enable policy audit logs
calicoctl patch felixconfiguration default --type='merge' -p '{"spec":{"policyAuditLogEnabled":true}}'

# View audit logs
kubectl logs -n calico-system ds/calico-node | grep "Policy audit"
```

---

## Troubleshooting

### Check Calico Logs

```bash
# View Calico node logs
kubectl logs -n calico-system ds/calico-node -c calico-node --tail=100 -f

# View Calico controller logs
kubectl logs -n calico-system deployment/calico-kube-controllers --tail=100 -f

# View Typha logs (if using Typha)
kubectl logs -n calico-system deployment/calico-typha --tail=100 -f
```

### Debug Network Issues

```bash
# Check node connectivity
calicoctl node status

# Check BGP peers
calicoctl node diags

# View workload endpoints
calicoctl get workloadendpoints --all-namespaces

# Check specific endpoint
calicoctl get workloadendpoint <endpoint-name> -o yaml
```

### Policy Troubleshooting

```bash
# View all policies
calicoctl get networkpolicy --all-namespaces
calicoctl get globalnetworkpolicy

# Check policy order
calicoctl get globalnetworkpolicy -o yaml | grep order

# Test policy with specific pod
calicoctl ipam show --show-blocks
```

### Common Issues

#### Issue: Pods can't communicate
```bash
# Check Calico status
calicoctl node status

# Verify IP pools
calicoctl get ippool -o wide

# Check routes
kubectl exec -n calico-system ds/calico-node -- ip route

# Restart Calico
kubectl rollout restart ds/calico-node -n calico-system
```

#### Issue: BGP not working
```bash
# Check BGP configuration
calicoctl get bgpconfig default -o yaml

# Check BGP peers
calicoctl node status

# View BGP logs
kubectl logs -n calico-system ds/calico-node | grep BGP
```

#### Issue: NetworkPolicy not enforced
```bash
# Check Felix configuration
calicoctl get felixconfiguration default -o yaml

# Verify policy syntax
kubectl describe networkpolicy <policy-name> -n <namespace>

# Check iptables rules
kubectl exec -n calico-system ds/calico-node -- iptables-save | grep <pod-ip>
```

---

## Cleanup

### Remove Demo Application
```bash
kubectl delete namespace calico-demo
calicoctl delete globalnetworkpolicy global-egress-control
```

### Uninstall Calico

```bash
# Operator-based installation
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# Manifest-based installation
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# Verify removal
kubectl get pods -n calico-system
kubectl get pods -n kube-system | grep calico
```

### Remove calicoctl CLI
```bash
sudo rm /usr/local/bin/calicoctl
```

---

## Best Practices

✅ **Use GlobalNetworkPolicy** for cluster-wide rules  
✅ **Enable encryption** for sensitive workloads (WireGuard)  
✅ **Use BGP** for on-premises deployments  
✅ **Enable eBPF mode** for better performance  
✅ **Monitor with Prometheus** for production  
✅ **Use IP pools** for network segmentation  
✅ **Enable audit logs** for compliance  
✅ **Protect host endpoints** for node security  
✅ **Test policies** before production deployment  
✅ **Keep Calico updated** for security patches  
✅ **Use Typha** for large clusters (>50 nodes)  
✅ **Document policies** for team knowledge  

---

## Resources

- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [Calico GitHub](https://github.com/projectcalico/calico)
- [GlobalNetworkPolicy Reference](https://docs.tigera.io/calico/latest/reference/resources/globalnetworkpolicy)
- [BGP Configuration](https://docs.tigera.io/calico/latest/networking/configuring/bgp)
- [Calico Slack Community](https://calicousers.slack.com/)

---

**Built with ❤️ for production-ready Kubernetes networking**
