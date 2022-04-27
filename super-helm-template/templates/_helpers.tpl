{{/*
Expand the name of the chart.
*/}}
{{- define "api-server.name" -}}
{{- default .Chart.Name .Values.app.serviceName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "api-server.fullname" -}}
{{- $name := default .Chart.Name .Values.app.serviceName }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "api-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "api-server.labels" -}}
helm.sh/chart: {{ include "api-server.chart" . }}
{{ include "api-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "api-server.ohouseLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "api-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "api-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Ohouse labels
*/}}
{{- define "api-server.ohouseLabels" -}}
tags.ohou.se/role: api
tags.ohou.se/service-name: {{ .Values.app.serviceName }}
tags.ohou.se/service-owner: {{ .Values.app.serviceOwner }}
tags.ohou.se/env: {{ include "api-server.delivery.env" . }}
tags.ohou.se/service: {{ .Values.app.serviceName }}
tags.ohou.se/version: {{ default .Values.image.tag .Values.image.version | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "api-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "api-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Convert application profile to Datadog profile.
*/}}
{{- define "api-server.delivery.env" -}}
{{- if eq .Values.app.profile "stage" }}
{{- printf "%s" "staging" }}
{{- else if eq .Values.app.profile "prod" }}
{{- printf "%s" "production" }}
{{- else if eq .Values.app.profile "qa" }}
{{- printf "%s" "qa" }}
{{- else if eq .Values.app.profile "sandbox" }}
{{- printf "%s" "sandbox" }}
{{- else }}
{{- printf "%s" "development" }}
{{- end }}
{{- end }}

{{- define "api-server.image-repository" -}}
{{- if .Values.ecr.enabled }}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s" .Values.ecr.accountID .Values.ecr.region .Values.image.repository }}
{{- else }}
{{- .Values.image.repository }}
{{- end }}
{{- end }}