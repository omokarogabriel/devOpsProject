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
echo "⏳ Waiting for Cilium to be ready..."
kubectl rollout status daemonset/cilium -n kube-system --timeout=120s

# Check status
echo "✅ Cilium installation complete!"
echo ""
echo "Run 'cilium status' to verify the installation"
