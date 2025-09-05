#!/bin/bash
set -e

NAMESPACE=${1:-elk}
RELEASE_NAME=${2:-elk-stack}

echo "Uninstalling ELK Stack..."
echo "Namespace: $NAMESPACE"
echo "Release: $RELEASE_NAME"

# Uninstall the release
helm uninstall $RELEASE_NAME --namespace $NAMESPACE

# Optionally delete the namespace
read -p "Delete namespace $NAMESPACE? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    echo "Namespace $NAMESPACE deleted"
fi

echo "Uninstallation completed!"