#!/bin/bash
set -e

echo "🚀 Deploying Cilium Demo Application with L7 Policies..."
echo ""

# Step 1: Namespace
echo "📦 Step 1/4: Creating namespace..."
kubectl apply -f namespace.yaml
sleep 2

# Step 2: Deploy Application Components
echo "🌐 Step 2/4: Deploying application components..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f database.yaml
kubectl apply -f database-statefulset.yaml
echo "   Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod --all -n cilium-demo --timeout=120s

# Step 3: Apply Cilium L7 Network Policies
echo "🔒 Step 3/4: Applying Cilium L7 network policies..."
kubectl apply -f l7-http-policy.yaml
kubectl apply -f dns-policy.yaml
sleep 2

# Step 4: Verification
echo "✅ Step 4/4: Verifying deployment..."
echo ""
echo "📊 Deployment Status:"
kubectl get all -n cilium-demo
echo ""
echo "🔐 Cilium Network Policies:"
kubectl get ciliumnetworkpolicies -n cilium-demo
echo ""
echo "✅ Deployment complete!"
echo ""
echo "🧪 Test L7 policies:"
echo ""
echo "   # Test GET (allowed)"
echo "   kubectl exec -n cilium-demo deployment/frontend -- wget -qO- http://backend"
echo ""
echo "   # Test POST (allowed)"
echo "   kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --post-data='test' http://backend"
echo ""
echo "   # Test DELETE (blocked by L7 policy)"
echo "   kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=DELETE http://backend"
echo ""
echo "   # Test PUT (blocked by L7 policy)"
echo "   kubectl exec -n cilium-demo deployment/frontend -- wget -qO- --method=PUT http://backend"
echo ""
echo "📈 Access Hubble UI:"
echo "   kubectl port-forward -n kube-system svc/hubble-ui 12000:80"
echo "   Open: http://localhost:12000"
echo ""
