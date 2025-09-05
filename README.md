# ELK Stack Helm Chart

A comprehensive Helm chart for deploying a complete ELK Stack (Elasticsearch, Logstash, Kibana) along with Filebeat, APM Server, and a demo Node.js application on Kubernetes.

## Features

- **Elasticsearch** - Search and analytics engine with SSL/TLS support
- **Kibana** - Data visualization and exploration tool
- **Logstash** - Server-side data processing pipeline
- **Filebeat** - Log shipping agent deployed as DaemonSet
- **APM Server** - Application Performance Monitoring
- **Demo Application** - Node.js app with APM integration for testing
- **Automatic SSL/TLS Certificate Generation**
- **RBAC Support**
- **Configurable Resources and Replicas**
- **Health Checks and Probes**
- **Post-install Configuration Jobs**

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (optional)

## Installation

### Quick Start

```bash
# Add the repository (if published)
helm repo add elk-stack https://your-repo-url

# Install with default values
helm install elk-stack ./elk-stack --namespace elk --create-namespace

# Or install from local chart
git clone <repository>
cd elk-stack-helm-chart
helm install elk-stack . --namespace elk --create-namespace
```

### Using Makefile

```bash
# Install the chart
make install

# View all available commands
make help
```

## Configuration

The following table lists the configurable parameters and their default values.

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.namespace` | Kubernetes namespace | `elk` |
| `global.elasticVersion` | Elastic Stack version | `9.1.3` |
| `global.filebeatVersion` | Filebeat version | `8.18.6` |

### Elasticsearch Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `elasticsearch.enabled` | Enable Elasticsearch | `true` |
| `elasticsearch.replicas` | Number of Elasticsearch replicas | `1` |
| `elasticsearch.auth.elasticPassword` | Elasticsearch elastic user password | `elasticpassword` |
| `elasticsearch.ssl.enabled` | Enable SSL/TLS | `true` |
| `elasticsearch.resources.requests.memory` | Memory request | `1Gi` |
| `elasticsearch.resources.requests.cpu` | CPU request | `500m` |
| `elasticsearch.resources.limits.memory` | Memory limit | `2Gi` |
| `elasticsearch.resources.limits.cpu` | CPU limit | `1000m` |
| `elasticsearch.persistence.enabled` | Enable persistent storage | `false` |
| `elasticsearch.persistence.size` | Storage size | `10Gi` |

### Kibana Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kibana.enabled` | Enable Kibana | `true` |
| `kibana.replicas` | Number of Kibana replicas | `1` |
| `kibana.auth.kibanaPassword` | Kibana system user password | `kibanapassword` |
| `kibana.service.type` | Kibana service type | `NodePort` |
| `kibana.service.nodePort` | Kibana NodePort | `30601` |
| `kibana.encryptionKey` | Encryption key for saved objects | `BqqvcUssLZUf1brzp2uaEVoiN7ej5tWg` |

### Logstash Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `logstash.enabled` | Enable Logstash | `true` |
| `logstash.replicas` | Number of Logstash replicas | `1` |
| `logstash.service.port` | Logstash beats input port | `5044` |

### Filebeat Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `filebeat.enabled` | Enable Filebeat | `true` |
| `filebeat.image.tag` | Filebeat image tag | `8.18.6` |

### APM Server Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `apmServer.enabled` | Enable APM Server | `true` |
| `apmServer.replicas` | Number of APM Server replicas | `1` |
| `apmServer.service.type` | APM Server service type | `NodePort` |
| `apmServer.service.nodePort` | APM Server NodePort | `30602` |

### Demo Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `demoApp.enabled` | Enable Demo Application | `true` |
| `demoApp.replicas` | Number of demo app replicas | `1` |
| `demoApp.service.nodePort` | Demo app NodePort | `30600` |

### Certificate Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `certificates.enabled` | Enable automatic certificate generation | `true` |
| `certificates.caValidityDays` | CA certificate validity in days | `3650` |
| `certificates.certValidityDays` | Server certificate validity in days | `3650` |

## Usage

### Accessing Services

After installation, you can access the services using the following methods:

#### Kibana
```bash
# Using NodePort (default)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Kibana: http://$NODE_IP:30601"

# Using port-forward
kubectl port-forward -n elk svc/kibana 5601:5601
echo "Kibana: http://localhost:5601"
```

#### Demo Application
```bash
# Using NodePort (default)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Demo App: http://$NODE_IP:30600"

# Using port-forward
kubectl port-forward -n elk svc/elk-stack-demo-app 3000:3000
echo "Demo App: http://localhost:3000"
```

#### APM Server
```bash
# Using NodePort (default)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
echo "APM Server: http://$NODE_IP:30602"
```

### Default Credentials

- **Username**: `elastic`
- **Password**: `elasticpassword` (configurable via `elasticsearch.auth.elasticPassword`)

### Demo Application Endpoints

The demo application provides several endpoints for testing:

- `GET /` - Hello World message
- `GET /health` - Health check endpoint
- `GET /slow` - Slow response (1-3 seconds)
- `GET /error` - Generates an error for testing
- `GET /database` - Simulates database query
- `POST /users` - Create user endpoint
- `GET /metrics` - Application metrics

### Generating Test Data

```bash
# Generate load using the Makefile
make generate-load

# Or manually
for i in {1..100}; do
  curl http://NODE_IP:30600/
  curl http://NODE_IP:30600/database
  curl http://NODE_IP:30600/slow
  sleep 1
done
```

### Monitoring and Troubleshooting

```bash
# Check pod status
kubectl get pods -n elk

# View logs
kubectl logs -n elk -l app.kubernetes.io/component=elasticsearch -f
kubectl logs -n elk -l app.kubernetes.io/component=kibana -f
kubectl logs -n elk -l app.kubernetes.io/component=logstash -f

# Test connectivity
make test-elasticsearch
make test-kibana

# Get service endpoints
kubectl get svc -n elk
```

## Customization

### Custom Values File

Create a `custom-values.yaml` file:

```yaml
elasticsearch:
  replicas: 3
  persistence:
    enabled: true
    size: 50Gi
    storageClassName: "fast-ssd"
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "2000m"

kibana:
  service:
    type: LoadBalancer

logstash:
  replicas: 2

demoApp:
  enabled: false
```

Install with custom values:
```bash
helm install elk-stack . -f custom-values.yaml --namespace elk --create-namespace
```

### SSL/TLS Configuration

SSL/TLS is enabled by default. The chart automatically generates:
- CA certificate and private key
- Elasticsearch server certificate with proper SANs
- PKCS12 keystore for Java applications

To disable SSL/TLS:
```yaml
elasticsearch:
  ssl:
    enabled: false
```

## Backup and Restore

### Elasticsearch Snapshots

```bash
# Create snapshot repository (example with filesystem)
curl -X PUT "localhost:9200/_snapshot/my_backup" \
-H "Content-Type: application/json" \
-d '{"type": "fs", "settings": {"location": "/backup"}}'

# Create snapshot
curl -X PUT "localhost:9200/_snapshot/my_backup/snapshot_1"
```

## Scaling

### Scale Elasticsearch
```bash
kubectl scale deployment elk-stack-elasticsearch --replicas=3 -n elk
```

### Scale Logstash
```bash
kubectl scale deployment elk-stack-logstash --replicas=2 -n elk
```

## Upgrades

```bash
# Upgrade using Helm
helm upgrade elk-stack . --namespace elk

# Or using Makefile
make upgrade
```

## Uninstalling

```bash
# Using Helm
helm uninstall elk-stack --namespace elk
kubectl delete namespace elk

# Using Makefile
make uninstall
```

## Development

### Chart Development

```bash
# Lint the chart
helm lint .

# Render templates
helm template elk-stack . --namespace elk

# Dry run
helm install elk-stack . --dry-run --debug --namespace elk
```

### Testing

```bash
# Run all tests
make validate

# Generate load for testing
make generate-load

# Check logs
make logs-elasticsearch
make logs-kibana
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This chart is licensed under the Apache License 2.0.

## Support

For issues and questions:
- Check the logs: `kubectl logs -n elk -l app.kubernetes.io/instance=elk-stack`
- Review the troubleshooting section
- Open an issue in the repository

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Demo App      │    │   Filebeat      │    │   APM Server    │
│   (Node.js)     │───▶│   (DaemonSet)   │───▶│                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Logstash                                │
│                    (Data Processing)                            │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Elasticsearch                              │
│                   (Search & Storage)                            │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Kibana                                   │
│                   (Visualization)                               │
└─────────────────────────────────────────────────────────────────┘
```