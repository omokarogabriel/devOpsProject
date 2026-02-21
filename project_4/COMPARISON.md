# Calico vs Cilium: Technical Comparison

## Executive Summary

| Aspect | Calico | Cilium |
|--------|--------|--------|
| **Best For** | Enterprise, on-prem, BGP routing | Cloud-native, microservices, API security |
| **Technology** | iptables (legacy) or eBPF | eBPF-native |
| **Maturity** | Very mature (2016) | Modern (2018, CNCF Graduated) |
| **Performance** | Good | Excellent (30-40% better) |
| **Learning Curve** | Moderate | Steep |
| **Policy Level** | L3/L4 (IP/Port) | L3/L4/L7 (HTTP/gRPC/DNS) |

## Detailed Comparison

### 1. Architecture

**Calico:**
- Uses Linux kernel networking (iptables or eBPF)
- BGP for routing between nodes
- Felix agent manages routing and ACLs
- BIRD for BGP peering
- Typha for scalability (optional)

**Cilium:**
- Pure eBPF implementation
- No iptables dependency
- Cilium agent runs on each node
- Hubble for observability
- Envoy proxy for L7 (optional)

### 2. Network Policies

**Calico:**
```yaml
# Standard Kubernetes NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy

# Calico-specific (cluster-wide)
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
```

**Cilium:**
```yaml
# Cilium-specific with L7 support
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy

# Cluster-wide
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
```

### 3. Policy Capabilities

| Feature | Calico | Cilium |
|---------|--------|--------|
| **L3/L4 (IP/Port)** | ✅ Excellent | ✅ Excellent |
| **L7 HTTP** | ⚠️ Limited | ✅ Full support |
| **L7 gRPC** | ❌ No | ✅ Yes |
| **DNS-based** | ⚠️ Basic | ✅ Advanced |
| **Kafka** | ❌ No | ✅ Yes |
| **Service Mesh** | ❌ Needs Istio | ✅ Built-in |

### 4. Performance Benchmarks

**Throughput (10Gbps network):**
- Calico (iptables): ~7.5 Gbps
- Calico (eBPF): ~8.5 Gbps
- Cilium (eBPF): ~9.2 Gbps

**Latency (p99):**
- Calico (iptables): ~2.5ms
- Calico (eBPF): ~1.8ms
- Cilium (eBPF): ~1.2ms

**CPU Usage (1000 pods):**
- Calico: ~15% per node
- Cilium: ~10% per node

### 5. Observability

**Calico:**
- Basic flow logs
- Prometheus metrics
- Requires external tools (Grafana, Kibana)
- No built-in UI

**Cilium:**
- Hubble UI (real-time visualization)
- Flow logs with L7 visibility
- Service dependency maps
- DNS query monitoring
- HTTP request/response inspection
- Prometheus metrics
- OpenTelemetry support

### 6. Security Features

**Calico:**
- Host endpoint protection
- Network policies (L3/L4)
- WireGuard encryption
- IPsec encryption
- Egress gateway
- Threat feeds integration

**Cilium:**
- Network policies (L3-L7)
- WireGuard encryption (transparent)
- Identity-based security
- API-aware filtering
- DNS security
- Transparent encryption
- Runtime security (Tetragon)

### 7. Scalability

**Calico:**
- Tested: 5000+ nodes
- 100,000+ pods
- Typha for scale
- BGP route reflectors

**Cilium:**
- Tested: 5000+ nodes
- 100,000+ pods
- ClusterMesh for multi-cluster
- eBPF maps for efficiency

### 8. Use Case Scenarios

**Choose Calico when:**
1. Running on-premises with BGP requirements
2. Need host-level security policies
3. Team familiar with traditional networking
4. Running older kernel versions (<4.19)
5. Need proven, battle-tested solution
6. Compliance requires mature technology

**Choose Cilium when:**
1. Building cloud-native microservices
2. Need L7 (HTTP/gRPC) policies
3. Want built-in observability
4. Running modern kernels (5.4+)
5. Need maximum performance
6. Want API-aware security
7. Building service mesh without sidecars

### 9. Installation Complexity

**Calico:**
```bash
# Simple installation
kubectl apply -f calico.yaml

# With operator
kubectl create -f tigera-operator.yaml
```

**Cilium:**
```bash
# Requires CLI tool
cilium install

# More configuration options
cilium install --set hubble.enabled=true
```

### 10. Enterprise Support

**Calico:**
- Tigera (Calico Enterprise)
- 24/7 support
- Advanced features (egress gateway, compliance reporting)
- Pricing: Contact sales

**Cilium:**
- Isovalent (Cilium Enterprise)
- 24/7 support
- Tetragon runtime security
- Pricing: Contact sales

## Real-World Adoption

**Calico:**
- AWS EKS (default option)
- Azure AKS (available)
- Google GKE (available)
- Used by: Adobe, Atlassian, Tigera customers

**Cilium:**
- Google GKE (Dataplane V2)
- AWS EKS Anywhere
- Used by: Google, AWS, Datadog, GitLab, Sky

## Migration Path

### From Calico to Cilium:
1. Backup existing policies
2. Install Cilium in migration mode
3. Convert policies to Cilium format
4. Test thoroughly
5. Remove Calico

### From Cilium to Calico:
1. Backup L7 policies (will need redesign)
2. Install Calico
3. Convert policies (L7 features lost)
4. Remove Cilium

## Recommendation Matrix

| Requirement | Recommendation |
|-------------|----------------|
| **On-premises + BGP** | Calico |
| **Cloud-native microservices** | Cilium |
| **L7 API security** | Cilium |
| **Maximum performance** | Cilium |
| **Mature/stable** | Calico |
| **Advanced observability** | Cilium |
| **Simple networking** | Calico |
| **Service mesh** | Cilium |
| **Older kernels** | Calico |
| **Modern kernels** | Cilium |

## Conclusion

**Both are excellent choices.** 

- **Calico** = Proven, stable, great for traditional environments
- **Cilium** = Modern, powerful, best for cloud-native workloads

For a DevOps portfolio, demonstrating knowledge of **both** shows comprehensive networking expertise.
