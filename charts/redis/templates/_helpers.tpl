{{- define "redis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "redis.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "redis.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "redis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "redis.labels" -}}
helm.sh/chart: {{ include "redis.chart" .root | quote }}
app.kubernetes.io/name: {{ include "redis.name" .root | quote }}
app.kubernetes.io/instance: {{ .root.Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .root.Release.Service | quote }}
app.kubernetes.io/component: {{ .component | quote }}
{{- with .root.Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis.name" .root | quote }}
app.kubernetes.io/instance: {{ .root.Release.Name | quote }}
app.kubernetes.io/component: {{ .component | quote }}
{{- end -}}

{{- define "redis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "redis.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "redis.authSecretName" -}}
{{- if .Values.auth.existingSecret -}}
{{- .Values.auth.existingSecret -}}
{{- else -}}
{{- printf "%s-auth" (include "redis.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "redis.primaryServiceName" -}}
{{- printf "%s-primary" (include "redis.fullname" .) -}}
{{- end -}}

{{- define "redis.primaryHeadlessServiceName" -}}
{{- printf "%s-primary-headless" (include "redis.fullname" .) -}}
{{- end -}}

{{- define "redis.replicaServiceName" -}}
{{- printf "%s-replica" (include "redis.fullname" .) -}}
{{- end -}}

{{- define "redis.replicaHeadlessServiceName" -}}
{{- printf "%s-replica-headless" (include "redis.fullname" .) -}}
{{- end -}}
