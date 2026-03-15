#!/bin/bash
# Cilium Helm Installation Script

set -e

echo "🚀 Installing Cilium via Helm..."

# Add Cilium Helm repository
echo "📦 Adding Cilium Helm repository..."
helm repo add cilium https://helm.cilium.io/
helm repo update

# Install or upgrade Cilium
echo "⚙️  Installing Cilium with custom values..."
helm upgrade --install cilium cilium/cilium \
  --version 1.19.0 \
  --namespace kube-system \
  --values values.yaml

# Wait for Cilium to be ready
echo "⏳ Waiting for Cilium DaemonSet to be ready..."
kubectl rollout status daemonset/cilium -n kube-system --timeout=300s

# Restart Hubble Relay to avoid DNS timeout on initial install
# (relay may start before Cilium agents are ready, causing CrashLoopBackOff)
echo "🔄 Restarting Hubble Relay..."
kubectl rollout restart deployment/hubble-relay -n kube-system 2>/dev/null || true
kubectl rollout status deployment/hubble-relay -n kube-system --timeout=60s 2>/dev/null || true

# Check status
echo ""
echo "✅ Cilium installation complete!"
echo ""
echo "Run 'cilium status' to verify the installation"
echo "Run 'kubectl port-forward -n kube-system svc/hubble-ui 12000:80' to access Hubble UI"
