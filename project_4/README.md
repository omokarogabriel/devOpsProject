# Project 4 — Advanced CNI Comparison: Calico vs Cilium

**Focus:** CNI plugins, advanced networking, performance comparison

A side-by-side comparison of two leading Kubernetes CNI plugins demonstrating their unique capabilities, advanced features, and use cases.

## 🎯 Overview

This project showcases the differences between Calico and Cilium by implementing identical workloads with CNI-specific features. It demonstrates when to choose each solution and highlights their strengths.

## 📂 Structure

```
project_4/
├── README.md           # This file
├── calico/            # Calico-specific implementation
│   └── README.md      # Calico setup and features
└── cilium/            # Cilium-specific implementation
    └── README.md      # Cilium setup and features
```

## 🔍 What's Demonstrated

### **Calico Implementation** (`./calico/`)
- GlobalNetworkPolicy for cluster-wide rules
- BGP peering configuration
- IP pool management
- Host endpoint protection
- Calico-specific policy features

### **Cilium Implementation** (`./cilium/`)
- L7 HTTP/gRPC policies
- Hubble observability setup
- Service mesh capabilities
- DNS-aware policies
- eBPF-native networking

## 🆚 Key Differences

| Feature | Calico | Cilium |
|---------|--------|--------|
| **Technology** | iptables/eBPF | eBPF-native |
| **Policy Level** | L3/L4 (IP/Port) | L3/L4/L7 (HTTP/gRPC) |
| **Observability** | Basic metrics | Hubble UI + Flow logs |
| **Service Mesh** | Requires Istio | Built-in |
| **Performance** | Good | Excellent |
| **Maturity** | Very mature | Modern |

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (v1.23+)
- `kubectl` CLI
- Cluster without existing CNI (or ability to replace)

### Choose Your Path

**Option 1: Calico Setup**
```bash
cd project_4/calico
# Follow the comprehensive setup guide
cat SETUP_GUIDE.md
# Or run automated deployment
./deploy.sh
```

**Option 2: Cilium Setup**
```bash
cd project_4/cilium
# Follow the comprehensive setup guide
cat SETUP_GUIDE.md
# Or run automated deployment
./deploy.sh
```

### Step-by-Step Guides Available

- **[Calico Setup Guide](./calico/SETUP_GUIDE.md)** — Complete installation, configuration, and advanced features
- **[Cilium Setup Guide](./cilium/SETUP_GUIDE.md)** — Complete installation, Hubble setup, and L7 policies

## 🎓 Learning Outcomes

- Understanding CNI plugin architecture
- Comparing iptables vs eBPF performance
- Implementing L7 network policies
- Setting up network observability
- Choosing the right CNI for your use case

## 📚 Resources

- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [Cilium Documentation](https://docs.cilium.io/)
- [CNCF CNI Specification](https://github.com/containernetworking/cni)

---

**Built with ❤️ for learning, sharing, and demonstrating DevOps excellence.**
