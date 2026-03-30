#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLUSTER_NAME="local"

# Create the cluster if it doesn't already exist
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "Cluster '${CLUSTER_NAME}' already exists, skipping creation."
else
  kind create cluster --name "${CLUSTER_NAME}" --config "${SCRIPT_DIR}/kind.yaml"
fi

KUBE_CONTEXT="kind-${CLUSTER_NAME}"

# Install the flux-operator via Helm
helm upgrade --install flux-operator \
  oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --create-namespace \
  --wait \
  --kube-context "${KUBE_CONTEXT}"

# Apply the FluxInstance to install Flux controllers
kubectl apply --context "${KUBE_CONTEXT}" -f "${SCRIPT_DIR}/flux-instance.yaml"
