{{- define "helm-charts-ci.fullname" -}}
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

{{- define "helm-charts-ci.commonLabels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{- define "helm-charts-ci.pipelineRunLabels" -}}
{{- include "helm-charts-ci.commonLabels" . }}
tekton.dev/pipeline: {{ .Values.pipeline.name | quote }}
harokilabs.com/tekton-run-id: "$(uid)"
{{- end -}}

{{- define "helm-charts-ci.workspaceLabels" -}}
{{- $root := .root -}}
{{- include "helm-charts-ci.commonLabels" $root }}
tekton.dev/pipeline: {{ $root.Values.pipeline.name | quote }}
harokilabs.com/tekton-run-id: "$(uid)"
harokilabs.com/tekton-workspace: {{ .workspace | quote }}
{{- end -}}
