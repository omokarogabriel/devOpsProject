#!/bin/bash
set -e

echo "🚀 Deploying Calico Demo Application..."
echo ""

# Step 1: Namespace
echo "📦 Step 1/7: Creating namespace..."
kubectl apply -f namespace.yaml
sleep 2

# Step 2: Resource Governance
echo "⚙️  Step 2/7: Applying resource governance..."
kubectl apply -f resourcequota.yaml
kubectl apply -f limitrange.yaml
sleep 2

# Step 3: Database
echo "💾 Step 3/7: Deploying database layer..."
kubectl apply -f database-secret.yaml
kubectl apply -f database-statefulset.yaml
kubectl apply -f database-service.yaml
echo "   Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=database -n calico-demo --timeout=120s

# Step 4: Backend
echo "🔧 Step 4/7: Deploying backend layer..."
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
echo "   Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n calico-demo --timeout=120s

# Step 5: Frontend
echo "🌐 Step 5/7: Deploying frontend layer..."
kubectl apply -f frontend-configmap.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
echo "   Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n calico-demo --timeout=120s

# Step 6: Network Policies
echo "🔒 Step 6/7: Applying network policies..."
kubectl apply -f 00-default-deny.yaml
kubectl apply -f 01-frontend-policy.yaml
kubectl apply -f 02-backend-policy.yaml
kubectl apply -f 03-database-policy.yaml
sleep 2

# Step 7: Global Policy (optional)
echo "🌍 Step 7/7: Checking for Calico..."
if kubectl get pods -n calico-system &>/dev/null; then
    echo "   Calico detected! Applying GlobalNetworkPolicy..."
    if command -v calicoctl &>/dev/null; then
        calicoctl apply -f 04-global-egress-policy.yaml
    else
        echo "   ⚠️  calicoctl not found. Skipping GlobalNetworkPolicy."
    fi
else
    echo "   ℹ️  Calico not detected. Skipping GlobalNetworkPolicy."
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Deployment Status:"
kubectl get all -n calico-demo
echo ""
echo "🔐 Network Policies:"
kubectl get networkpolicies -n calico-demo
echo ""
echo "🧪 Test connectivity:"
echo "   kubectl exec -n calico-demo deployment/frontend -- wget -qO- http://backend"
