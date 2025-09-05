{{/*
Expand the name of the chart.
*/}}
{{- define "elk-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "elk-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "elk-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "elk-stack.labels" -}}
helm.sh/chart: {{ include "elk-stack.chart" . }}
{{ include "elk-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "elk-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Elasticsearch selector labels
*/}}
{{- define "elk-stack.elasticsearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}-elasticsearch
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: elasticsearch
{{- end }}

{{/*
Kibana selector labels
*/}}
{{- define "elk-stack.kibana.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}-kibana
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: kibana
{{- end }}

{{/*
Logstash selector labels
*/}}
{{- define "elk-stack.logstash.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}-logstash
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: logstash
{{- end }}

{{/*
Filebeat selector labels
*/}}
{{- define "elk-stack.filebeat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}-filebeat
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: filebeat
{{- end }}

{{/*
APM Server selector labels
*/}}
{{- define "elk-stack.apmserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}-apm-server
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: apm-server
{{- end }}

{{/*
Demo App selector labels
*/}}
{{- define "elk-stack.demoapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elk-stack.name" . }}-demo-app
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: demo-app
{{- end }}

{{/*
Create the name of the service account to use for Filebeat
*/}}
{{- define "elk-stack.filebeat.serviceAccountName" -}}
{{- printf "%s-filebeat" (include "elk-stack.fullname" .) }}
{{- end }}