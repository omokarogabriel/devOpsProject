# Project 5 — HPA, PDB & Karpenter Autoscaling

**Focus:** Horizontal Pod Autoscaling, Pod Disruption Budgets, Karpenter node autoscaling on AWS

## 🎯 Overview

A production-grade 3-tier application demonstrating pod-level and node-level autoscaling with disruption protection.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│  Karpenter (Node Autoscaling)                       │
│  ┌───────────────────────────────────────────────┐  │
│  │  HPA + PDB                                    │  │
│  │                                               │  │
│  │  Frontend (Nginx) ──→ Backend (API) ──→ DB    │  │
│  │  HPA: 2-10 pods       HPA: 2-10 pods  Redis  │  │
│  │  PDB: minAvail=1      PDB: minAvail=1 PDB=1  │  │
│  └───────────────────────────────────────────────┘  │
│  NodePool: t3.medium/large/xlarge (spot + on-demand)│
└─────────────────────────────────────────────────────┘
```

## ✨ Key Features

- **HPA** — CPU/memory-based autoscaling (2→10 replicas) with scale-up/down policies
- **PDB** — Guarantees minimum availability during voluntary disruptions
- **Karpenter** — Node autoscaling with spot + on-demand, consolidation
- **Security** — Non-root, read-only filesystem, dropped capabilities
- **Zero-downtime** — Rolling updates with maxUnavailable: 0
- **Resource Governance** — ResourceQuota and LimitRange for namespace-level control
- **Metrics Server** — Helm-managed cluster metrics for HPA and kubectl top

## 🚀 Deploy

```bash
chmod +x deploy.sh
./deploy.sh
```

Or manually:

```bash
kubectl apply -f namespace.yaml
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system --set args={--kubelet-insecure-tls}
kubectl apply -f resourcequota.yaml -f limitrange.yaml
kubectl apply -f database-secret.yaml -f database-service.yaml -f database-statefulset.yaml
kubectl apply -f backend-deployment.yaml -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml -f frontend-service.yaml
kubectl apply -f hpa.yaml
kubectl apply -f pdb.yaml
kubectl apply -f karpenter.yaml  # AWS EKS only
```

## 🔍 Validation

### Check Metrics Server

```bash
kubectl top nodes
kubectl top pods -n project-5
```

### Check HPA

```bash
kubectl get hpa -n project-5
kubectl describe hpa frontend-hpa -n project-5
```

### Check PDB

```bash
kubectl get pdb -n project-5
kubectl describe pdb frontend-pdb -n project-5
```

### Check Karpenter (AWS)

```bash
kubectl get nodepool
kubectl get ec2nodeclass
kubectl get nodeclaim
```

### Load Test (trigger HPA)

```bash
kubectl run load-test --image=busybox -n project-5 --rm -it -- sh -c \
  "while true; do wget -qO- http://frontend; done"
```

Watch scaling:

```bash
kubectl get hpa -n project-5 -w
kubectl get pods -n project-5 -w
```

## 📋 HPA Behavior

| Metric | Target | Scale Up | Scale Down |
|--------|--------|----------|------------|
| CPU | 70% | +2 pods / 60s | -1 pod / 60s |
| Memory | 80% | +2 pods / 60s | -1 pod / 60s |
| Stabilization (up) | 30s | — | — |
| Stabilization (down) | 300s | — | — |

## 📋 Karpenter Config

| Setting | Value |
|---------|-------|
| Instance types | t3.medium, t3.large, t3.xlarge |
| Capacity | spot + on-demand |
| Architecture | amd64 |
| Limits | 20 CPU, 40Gi memory |
| Consolidation | WhenEmptyOrUnderutilized (60s) |

## 🧹 Cleanup

```bash
kubectl delete namespace project-5
kubectl delete nodepool project-5-pool
kubectl delete ec2nodeclass project-5-nodeclass
```
