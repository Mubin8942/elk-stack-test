#!/bin/bash
set -e

NAMESPACE=${1:-elk}
RELEASE_NAME=${2:-elk-stack}
VALUES_FILE=${3:-values.yaml}

echo "Installing ELK Stack..."
echo "Namespace: $NAMESPACE"
echo "Release: $RELEASE_NAME"
echo "Values: $VALUES_FILE"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Install the chart
helm install $RELEASE_NAME . \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait \
  --timeout=15m

echo "Installation completed!"
echo "Run 'kubectl get pods -n $NAMESPACE' to check pod status"