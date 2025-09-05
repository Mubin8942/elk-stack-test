#!/bin/bash

NAMESPACE=${1:-elk}

echo "Setting up port forwarding for ELK Stack services..."

# Kill existing port-forward processes
pkill -f "port-forward.*$NAMESPACE" || true

# Port forward services
kubectl port-forward -n $NAMESPACE svc/kibana 5601:5601 &
kubectl port-forward -n $NAMESPACE svc/elasticsearch 9200:9200 &
kubectl port-forward -n $NAMESPACE svc/elk-stack-demo-app 3000:3000 &
kubectl port-forward -n $NAMESPACE svc/apm-server 8200:8200 &

echo "Port forwarding established:"
echo "  Kibana:        http://localhost:5601"
echo "  Elasticsearch: http://localhost:9200"
echo "  Demo App:      http://localhost:3000"
echo "  APM Server:    http://localhost:8200"
echo ""
echo "Press Ctrl+C to stop all port forwards"

# Wait for interrupt
trap "pkill -f 'port-forward.*$NAMESPACE'; exit 0" INT
wait