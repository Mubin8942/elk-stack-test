# ELK Stack Helm Chart Makefile

CHART_NAME := elk-stack
NAMESPACE := elk
RELEASE_NAME := elk-stack

.PHONY: help
help: ## Display this help message
	@echo "ELK Stack Helm Chart Management"
	@echo "================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: lint
lint: ## Lint the Helm chart
	helm lint .

.PHONY: template
template: ## Generate templates without installing
	helm template $(RELEASE_NAME) . --namespace $(NAMESPACE)

.PHONY: dry-run
dry-run: ## Perform a dry-run install
	helm install $(RELEASE_NAME) . --namespace $(NAMESPACE) --create-namespace --dry-run --debug

.PHONY: install
install: ## Install the ELK stack
	helm install $(RELEASE_NAME) . --namespace $(NAMESPACE) --create-namespace --wait --timeout=10m

.PHONY: upgrade
upgrade: ## Upgrade the ELK stack
	helm upgrade $(RELEASE_NAME) . --namespace $(NAMESPACE) --wait --timeout=10m

.PHONY: uninstall
uninstall: ## Uninstall the ELK stack
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE)
	kubectl delete namespace $(NAMESPACE) --ignore-not-found=true

.PHONY: status
status: ## Show the status of the release
	helm status $(RELEASE_NAME) --namespace $(NAMESPACE)

.PHONY: get-pods
get-pods: ## Get all pods in the namespace
	kubectl get pods -n $(NAMESPACE) -o wide

.PHONY: get-services
get-services: ## Get all services in the namespace
	kubectl get services -n $(NAMESPACE) -o wide

.PHONY: logs-elasticsearch
logs-elasticsearch: ## View Elasticsearch logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=elasticsearch -f

.PHONY: logs-kibana
logs-kibana: ## View Kibana logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=kibana -f

.PHONY: logs-logstash
logs-logstash: ## View Logstash logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=logstash -f

.PHONY: logs-filebeat
logs-filebeat: ## View Filebeat logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=filebeat -f

.PHONY: logs-apm
logs-apm: ## View APM Server logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=apm-server -f

.PHONY: logs-demo
logs-demo: ## View Demo App logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=demo-app -f

.PHONY: port-forward-kibana
port-forward-kibana: ## Port forward to Kibana
	kubectl port-forward -n $(NAMESPACE) svc/kibana 5601:5601

.PHONY: port-forward-elasticsearch
port-forward-elasticsearch: ## Port forward to Elasticsearch
	kubectl port-forward -n $(NAMESPACE) svc/elasticsearch 9200:9200

.PHONY: port-forward-demo
port-forward-demo: ## Port forward to Demo App
	kubectl port-forward -n $(NAMESPACE) svc/elk-stack-demo-app 3000:3000

.PHONY: get-passwords
get-passwords: ## Get passwords for the services
	@echo "Elasticsearch Password: $$(kubectl get secret -n $(NAMESPACE) elk-stack-elasticsearch-secrets -o jsonpath='{.data.password}' | base64 -d)"
	@echo "Kibana Password: $$(kubectl get secret -n $(NAMESPACE) elk-stack-kibana-secrets -o jsonpath='{.data.password}' | base64 -d)"

.PHONY: test-elasticsearch
test-elasticsearch: ## Test Elasticsearch connectivity
	kubectl exec -n $(NAMESPACE) deployment/elk-stack-elasticsearch -- curl -k -u elastic:elasticpassword https://localhost:9200/_cluster/health?pretty

.PHONY: test-kibana
test-kibana: ## Test Kibana connectivity
	kubectl exec -n $(NAMESPACE) deployment/elk-stack-kibana -- curl -f http://localhost:5601/api/status

.PHONY: generate-load
generate-load: ## Generate load for the demo app
	@echo "Generating load for demo app..."
	@for i in $$(seq 1 50); do \
		echo "Request $$i"; \
		kubectl exec -n $(NAMESPACE) deployment/elk-stack-demo-app -- wget -q -O - http://localhost:3000/ > /dev/null; \
		kubectl exec -n $(NAMESPACE) deployment/elk-stack-demo-app -- wget -q -O - http://localhost:3000/database > /dev/null; \
		kubectl exec -n $(NAMESPACE) deployment/elk-stack-demo-app -- wget -q -O - http://localhost:3000/slow > /dev/null; \
		if [ $$((i % 10)) -eq 0 ]; then \
			kubectl exec -n $(NAMESPACE) deployment/elk-stack-demo-app -- wget -q -O - http://localhost:3000/error > /dev/null || true; \
		fi; \
		sleep 1; \
	done

.PHONY: package
package: ## Package the Helm chart
	helm package .

.PHONY: clean
clean: ## Clean up generated files
	rm -f *.tgz

.PHONY: validate
validate: lint template ## Validate the chart (lint + template)

.PHONY: reset
reset: uninstall install ## Reset the installation (uninstall + install)

.PHONY: watch-pods
watch-pods: ## Watch pod status changes
	watch kubectl get pods -n $(NAMESPACE)

.PHONY: describe-pods
describe-pods: ## Describe all pods
	kubectl describe pods -n $(NAMESPACE)

.PHONY: get-events
get-events: ## Get events in the namespace
	kubectl get events -n $(NAMESPACE) --sort-by=.metadata.creationTimestamp