{{- define "tekton-ci.fullname" -}}
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

{{- define "tekton-ci.commonLabels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{- define "tekton-ci.pipelineRunLabels" -}}
{{- include "tekton-ci.commonLabels" . }}
tekton.dev/pipeline: {{ include "tekton-ci.pipelineName" . | quote }}
harokilabs.com/tekton-run-id: "$(uid)"
{{- end -}}

{{- define "tekton-ci.workspaceLabels" -}}
{{- $root := .root -}}
{{- include "tekton-ci.commonLabels" $root }}
tekton.dev/pipeline: {{ include "tekton-ci.pipelineName" $root | quote }}
harokilabs.com/tekton-run-id: "$(uid)"
harokilabs.com/tekton-workspace: {{ .workspace | quote }}
{{- end -}}

{{- define "tekton-ci.pipelineName" -}}
{{- printf "%s-%s" (include "tekton-ci.fullname" .) .Values.pipeline.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tekton-ci.triggerBindingName" -}}
{{- .Values.triggerBinding.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tekton-ci.triggerTemplateName" -}}
{{- .Values.triggerTemplate.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tekton-ci.singleListenerName" -}}
{{- .Values.eventListener.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tekton-ci.perTriggerListenerName" -}}
{{- $root := .root -}}
{{- $trigger := .trigger -}}
{{- printf "%s-%s" (include "tekton-ci.fullname" $root) $trigger.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tekton-ci.triggerRoutePath" -}}
{{- $root := .root -}}
{{- $trigger := .trigger -}}
{{- if hasKey $root.Values.httpRoute.routePathPrefixByTrigger $trigger.name -}}
{{- get $root.Values.httpRoute.routePathPrefixByTrigger $trigger.name -}}
{{- else -}}
{{- printf "/%s/" $trigger.name -}}
{{- end -}}
{{- end -}}

{{- define "tekton-ci.changedFilesPredicate" -}}
{{- $trigger := .trigger -}}
{{- $first := true -}}
{{- range $path := $trigger.pathFilters -}}
{{- if not $first }} || {{ end -}}extensions.changed_files.matches('(^|,){{ $path }}')
{{- $first = false -}}
{{- end -}}
{{- end -}}

{{- define "tekton-ci.commitPathPredicate" -}}
{{- $trigger := .trigger -}}
{{- $first := true -}}
{{- range $path := $trigger.pathFilters -}}
{{- if not $first }} || {{ end -}}
commit.modified.exists(path, path.matches('^{{ $path }}')) ||
commit.added.exists(path, path.matches('^{{ $path }}')) ||
commit.removed.exists(path, path.matches('^{{ $path }}'))
{{- $first = false -}}
{{- end -}}
{{- end -}}

{{- define "tekton-ci.celFilter" -}}
{{- $root := .root -}}
{{- $trigger := .trigger -}}
body.repository.full_name == '{{ $trigger.repoFullName }}'
{{- if $root.Values.eventListener.includeChangedFiles }}
&& ({{ include "tekton-ci.changedFilesPredicate" (dict "trigger" $trigger) }})
{{- else }}
&& body.commits.exists(commit, {{ include "tekton-ci.commitPathPredicate" (dict "trigger" $trigger) }})
{{- end }}
{{- range $extra := $trigger.extraCelFilters }}
&& ({{ $extra }})
{{- end }}
{{- end -}}
