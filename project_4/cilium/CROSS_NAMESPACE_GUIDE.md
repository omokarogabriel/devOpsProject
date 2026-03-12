# Cross-Namespace Traffic Guide

A comprehensive guide on how to allow and control cross-namespace communication in Cilium with network policies.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Default Behavior](#default-behavior)
3. [Allow Specific Namespace](#allow-specific-namespace)
4. [Allow by Namespace Label](#allow-by-namespace-label)
5. [Allow All Namespaces](#allow-all-namespaces)
6. [Cluster-Wide Policies](#cluster-wide-policies)
7. [Practical Examples](#practical-examples)
8. [Best Practices](#best-practices)

---

## Overview

By default, the namespace isolation policy blocks all cross-namespace traffic. This guide shows how to selectively allow communication between namespaces.

---

## Default Behavior

With namespace isolation enabled:

```yaml
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: namespace-isolation
spec:
  endpointSelector: {}
  ingress:
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: cilium-demo
  egress:
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: cilium-demo
```

**Result:**
- ✅ Pods within `cilium-demo` can communicate
- ❌ Pods from other namespaces are blocked
- ✅ DNS queries to `kube-system` are allowed

---

## Allow Specific Namespace

### Ingress: Allow Traffic FROM Another Namespace

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-from-production
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  # Allow from production namespace
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: production
        app: api-gateway
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

**Use case:** Allow production API gateway to access cilium-demo backend

---

### Egress: Allow Traffic TO Another Namespace

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-to-external-api
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  egress:
  # Allow to external-api namespace
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: external-api
        app: payment-service
    toPorts:
    - ports:
      - port: "443"
        protocol: TCP
```

**Use case:** Allow cilium-demo backend to call external payment service

---

## Allow by Namespace Label

### Multiple Namespaces

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-trusted-namespaces
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  # Allow from multiple namespaces
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: production
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: staging
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: development
```

**Use case:** Allow access from multiple environments

---

### Using Namespace Labels

First, label your namespaces:

```bash
kubectl label namespace production environment=trusted
kubectl label namespace staging environment=trusted
```

Then create policy:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-trusted-environments
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace.labels.environment: trusted
```

**Use case:** Manage access by environment classification

---

## Allow All Namespaces

### ⚠️ Not Recommended (Use with Caution)

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-all-namespaces
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: public-api
  ingress:
  # Allow from any namespace
  - fromEndpoints:
    - {}
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

**Use case:** Public API that needs to be accessible from anywhere (rare)

---

## Cluster-Wide Policies

### Allow Monitoring Namespace to Access All

```yaml
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: allow-monitoring-everywhere
spec:
  endpointSelector:
    matchLabels:
      k8s:io.kubernetes.pod.namespace: monitoring
  egress:
  # Allow monitoring to scrape metrics from all namespaces
  - toEndpoints:
    - {}
    toPorts:
    - ports:
      - port: "9090"
        protocol: TCP
```

**Use case:** Prometheus needs to scrape metrics from all namespaces

---

### Allow Ingress Controller

```yaml
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: allow-ingress-controller
spec:
  endpointSelector:
    matchLabels:
      k8s:io.kubernetes.pod.namespace: ingress-nginx
  egress:
  # Allow ingress controller to route to all namespaces
  - toEndpoints:
    - {}
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
      - port: "443"
        protocol: TCP
```

**Use case:** Ingress controller needs to route traffic to any namespace

---

## Practical Examples

### Example 1: Microservices Across Namespaces

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-microservices
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  # Allow from frontend in different namespace
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: frontend-ns
        app: web-app
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
      rules:
        http:
        - method: "GET"
          path: "/api/.*"
        - method: "POST"
          path: "/api/.*"
  
  egress:
  # Allow to database in different namespace
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: database-ns
        app: postgres
    toPorts:
    - ports:
      - port: "5432"
        protocol: TCP
```

---

### Example 2: Allow Prometheus Monitoring

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-prometheus-scraping
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      metrics: enabled
  ingress:
  # Allow Prometheus to scrape metrics
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: monitoring
        app: prometheus
    toPorts:
    - ports:
      - port: "9090"
        protocol: TCP
```

---

### Example 3: Service Mesh Communication

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: service-mesh-communication
  namespace: cilium-demo
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  # Allow from service mesh sidecar
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: istio-system
        app: istio-ingressgateway
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
  
  egress:
  # Allow to service mesh control plane
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: istio-system
        app: istiod
    toPorts:
    - ports:
      - port: "15012"
        protocol: TCP
```

---

### Example 4: Multi-Tenant Application

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: tenant-isolation
  namespace: tenant-a
spec:
  endpointSelector:
    matchLabels:
      app: api
  ingress:
  # Only allow from same tenant namespace
  - fromEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: tenant-a
  
  egress:
  # Allow to shared services namespace
  - toEndpoints:
    - matchLabels:
        k8s:io.kubernetes.pod.namespace: shared-services
        app: auth-service
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
```

---

## Best Practices

### ✅ DO

1. **Always specify both namespace AND app label**
   ```yaml
   matchLabels:
     k8s:io.kubernetes.pod.namespace: production
     app: api-gateway
   ```

2. **Use L7 policies when possible**
   ```yaml
   rules:
     http:
     - method: "GET"
       path: "/api/.*"
   ```

3. **Document why cross-namespace access is needed**
   ```yaml
   metadata:
     annotations:
       description: "Allow production API gateway to access backend for user authentication"
   ```

4. **Use least privilege principle**
   - Only allow specific ports
   - Only allow specific HTTP methods
   - Only allow specific paths

5. **Test policies before production**
   ```bash
   # Test from source namespace
   kubectl exec -n production deployment/api-gateway -- curl http://backend.cilium-demo.svc.cluster.local
   ```

---

### ❌ DON'T

1. **Don't allow all namespaces unless absolutely necessary**
   ```yaml
   # Avoid this
   fromEndpoints:
   - {}
   ```

2. **Don't use overly broad selectors**
   ```yaml
   # Too broad
   matchLabels:
     k8s:io.kubernetes.pod.namespace: production
   
   # Better - more specific
   matchLabels:
     k8s:io.kubernetes.pod.namespace: production
     app: api-gateway
     version: v2
   ```

3. **Don't forget DNS access**
   ```yaml
   # Always include DNS for cross-namespace communication
   egress:
   - toEndpoints:
     - matchLabels:
         k8s:io.kubernetes.pod.namespace: kube-system
         k8s:k8s-app: kube-dns
     toPorts:
     - ports:
       - port: "53"
         protocol: UDP
   ```

---

## Testing Cross-Namespace Policies

### Test Allowed Traffic

```bash
# From production namespace to cilium-demo
kubectl exec -n production deployment/api-gateway -- \
  curl http://backend.cilium-demo.svc.cluster.local:8080
```

### Test Blocked Traffic

```bash
# From unauthorized namespace (should fail)
kubectl exec -n unauthorized deployment/test-pod -- \
  curl http://backend.cilium-demo.svc.cluster.local:8080
```

### View Policy Enforcement

```bash
# Check Cilium policies
kubectl get ciliumnetworkpolicies -A

# View policy details
kubectl describe ciliumnetworkpolicy allow-from-production -n cilium-demo

# Check with Hubble
hubble observe --namespace cilium-demo --verdict DROPPED
```

---

## Troubleshooting

### Traffic is Blocked

1. **Check policy exists**
   ```bash
   kubectl get ciliumnetworkpolicies -n cilium-demo
   ```

2. **Verify labels match**
   ```bash
   kubectl get pods -n production --show-labels
   kubectl get pods -n cilium-demo --show-labels
   ```

3. **Check Hubble for drops**
   ```bash
   hubble observe --verdict DROPPED --namespace cilium-demo
   ```

4. **Verify DNS works**
   ```bash
   kubectl exec -n production deployment/api-gateway -- \
     nslookup backend.cilium-demo.svc.cluster.local
   ```

---

## Summary

| Scenario | Policy Type | Selector |
|----------|-------------|----------|
| Allow specific namespace | CiliumNetworkPolicy | `k8s:io.kubernetes.pod.namespace: production` |
| Allow multiple namespaces | CiliumNetworkPolicy | Multiple `matchLabels` entries |
| Allow by namespace label | CiliumNetworkPolicy | `k8s:io.kubernetes.pod.namespace.labels.env: prod` |
| Allow monitoring everywhere | CiliumClusterwideNetworkPolicy | `endpointSelector` for monitoring |
| Allow ingress controller | CiliumClusterwideNetworkPolicy | `endpointSelector` for ingress |

---

**Key Takeaway:** Cross-namespace traffic requires explicit allow rules. Always use the most specific selectors possible for security! 🔒
