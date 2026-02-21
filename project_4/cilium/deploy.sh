#!/bin/bash
set -e

echo "🚀 Deploying Cilium Demo Application with L7 Policies..."
echo ""

# Step 1: Namespace
echo "📦 Step 1/6: Creating namespace..."
kubectl apply -f namespace.yaml
sleep 2

# Step 2: Resource Governance
echo "⚙️  Step 2/6: Applying resource governance..."
kubectl apply -f resources.yaml
sleep 2

# Step 3: Database
echo "💾 Step 3/6: Deploying database layer..."
kubectl apply -f database.yaml
kubectl apply -f database-statefulset.yaml
echo "   Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=database -n cilium-demo --timeout=120s

# Step 4: Backend
echo "🔧 Step 4/6: Deploying backend layer..."
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
echo "   Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n cilium-demo --timeout=120s

# Step 5: Frontend
echo "🌐 Step 5/6: Deploying frontend layer..."
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
echo "   Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n cilium-demo --timeout=120s

# Step 6: Cilium L7 Network Policies
echo "🔒 Step 6/6: Applying Cilium L7 network policies..."
kubectl apply -f 00-default-deny.yaml
kubectl apply -f 01-frontend-policy.yaml
kubectl apply -f 02-backend-policy.yaml
kubectl apply -f 03-database-policy.yaml
sleep 2

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Deployment Status:"
kubectl get all -n cilium-demo
echo ""
echo "🔐 Cilium Network Policies:"
kubectl get ciliumnetworkpolicies -n cilium-demo
echo ""
echo "🧪 Test L7 policies:"
echo "   # Test GET (allowed)"
echo "   kubectl exec -n cilium-demo deployment/frontend -- wget -qO- http://backend"
echo ""
echo "   # Test DELETE (blocked by L7 policy)"
echo "   kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=DELETE http://backend"
