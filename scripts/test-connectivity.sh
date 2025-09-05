#!/bin/bash

NAMESPACE=${1:-elk}

echo "Testing ELK Stack connectivity..."

# Test Elasticsearch
echo "Testing Elasticsearch..."
kubectl exec -n $NAMESPACE deployment/elk-stack-elasticsearch -- \
  curl -k -s -u elastic:elasticpassword https://localhost:9200/_cluster/health?pretty

# Test Kibana
echo "Testing Kibana..."
kubectl exec -n $NAMESPACE deployment/elk-stack-kibana -- \
  curl -s http://localhost:5601/api/status | jq .status.overall.state

# Test Demo App
echo "Testing Demo App..."
kubectl exec -n $NAMESPACE deployment/elk-stack-demo-app -- \
  curl -s http://localhost:3000/health | jq .

# Test APM Server
echo "Testing APM Server..."
kubectl exec -n $NAMESPACE deployment/elk-stack-apm-server -- \
  curl -s http://localhost:8200/ | head -1

echo "Connectivity tests completed!"