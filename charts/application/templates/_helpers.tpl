{{- define "application.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Chart.Name -}}
{{- if .Values.nameOverride -}}
{{- $name = .Values.nameOverride -}}
{{- end -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "application.deploymentName" -}}
{{- if .Values.deploymentNameOverride -}}
{{- .Values.deploymentNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "application.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "application.commonLabels" -}}
{{- $name := .Chart.Name -}}
{{- if .Values.nameOverride -}}
{{- $name = .Values.nameOverride -}}
{{- end -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/name: {{ $name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{- define "application.selectorLabels" -}}
{{- $name := .Chart.Name -}}
{{- if .Values.nameOverride -}}
{{- $name = .Values.nameOverride -}}
{{- end -}}
app.kubernetes.io/name: {{ $name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{- define "application.effectiveSelectorLabels" -}}
{{- if and .Values.selectorLabels (gt (len .Values.selectorLabels) 0) -}}
{{- toYaml .Values.selectorLabels -}}
{{- else -}}
{{- include "application.selectorLabels" . -}}
{{- end -}}
{{- end -}}

{{- define "application.serviceName" -}}
{{- $root := index . 0 -}}
{{- $service := index . 1 -}}
{{- if eq (default "prefixed" $root.Values.resourceNameStrategy) "exact" -}}
{{- $service.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "application.fullname" $root) $service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "application.pvcName" -}}
{{- $root := index . 0 -}}
{{- $pvc := index . 1 -}}
{{- if eq (default "prefixed" $root.Values.resourceNameStrategy) "exact" -}}
{{- $pvc.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "application.fullname" $root) $pvc.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "application.httpRouteName" -}}
{{- $root := index . 0 -}}
{{- $route := index . 1 -}}
{{- if eq (default "prefixed" $root.Values.resourceNameStrategy) "exact" -}}
{{- $route.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "application.fullname" $root) $route.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
