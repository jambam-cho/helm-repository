{{/*
Expand the name of the chart.
*/}}
{{- define "super-helm-template.name" -}}
{{- default .Chart.Name .Values.app.serviceName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "super-helm-template.fullname" -}}
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
{{- define "super-helm-template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "super-helm-template.labels" -}}
helm.sh/chart: {{ include "super-helm-template.chart" . }}
{{ include "super-helm-template.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "super-helm-template.ohouseLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "super-helm-template.selectorLabels" -}}
app.kubernetes.io/name: {{ include "super-helm-template.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Ohouse labels
*/}}
{{- define "super-helm-template.ohouseLabels" -}}
tags.ohou.se/role: api
tags.ohou.se/service-name: {{ .Values.app.serviceName }}
tags.ohou.se/service-owner: {{ .Values.app.serviceOwner }}
tags.ohou.se/env: {{ include "super-helm-template.delivery.env" . }}
tags.ohou.se/service: {{ .Values.app.serviceName }}
tags.ohou.se/version: {{ default .Values.image.tag .Values.image.version | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "super-helm-template.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "super-helm-template.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Convert application profile to Datadog profile.
*/}}
{{- define "super-helm-template.delivery.env" -}}
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

{{- define "super-helm-template.image-repository" -}}
{{- if .Values.ecr.enabled }}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s" .Values.ecr.accountID .Values.ecr.region .Values.image.repository }}
{{- else }}
{{- .Values.image.repository }}
{{- end }}
{{- end }}