#!/bin/bash
set -e

echo "=== Deploying Project 5: HPA, PDB & Karpenter ==="

echo "1. Creating namespace..."
kubectl apply -f namespace.yaml

echo "2. Installing metrics-server (Helm)..."
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 2>/dev/null || true
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls} \
  --wait --timeout 120s

echo "3. Applying resource governance..."
kubectl apply -f resourcequota.yaml
kubectl apply -f limitrange.yaml

echo "4. Deploying database..."
kubectl apply -f database-secret.yaml
kubectl apply -f configmap.yaml
kubectl apply -f database-service.yaml
kubectl apply -f database-statefulset.yaml

echo "5. Deploying backend..."
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

echo "6. Deploying frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

echo "7. Applying HPA..."
kubectl apply -f hpa.yaml

echo "8. Applying PDB..."
kubectl apply -f pdb.yaml

echo "9. Applying Karpenter (AWS only)..."
kubectl apply -f karpenter.yaml 2>/dev/null || echo "   Skipped: Karpenter CRDs not found (requires AWS EKS)"

echo ""
echo "=== Waiting for pods ==="
kubectl wait --for=condition=ready pod -l tier=database -n project-5 --timeout=120s
kubectl wait --for=condition=ready pod -l tier=backend -n project-5 --timeout=120s
kubectl wait --for=condition=ready pod -l tier=frontend -n project-5 --timeout=120s

echo ""
echo "=== Deployment Complete ==="
kubectl get all -n project-5
echo ""
kubectl get hpa -n project-5
echo ""
kubectl get pdb -n project-5
