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
