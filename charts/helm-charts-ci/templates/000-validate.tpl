{{- if not .Values.github.repositoryFullName -}}
{{- fail "github.repositoryFullName must be set" -}}
{{- end -}}
{{- if and .Values.httpRoute.enabled (eq (len .Values.httpRoute.parentRefs) 0) -}}
{{- fail "httpRoute.enabled=true requires httpRoute.parentRefs with at least one entry" -}}
{{- end -}}
{{- if and .Values.httpRoute.enabled (not .Values.httpRoute.pathPrefix) -}}
{{- fail "httpRoute.enabled=true requires httpRoute.pathPrefix" -}}
{{- end -}}
{{- if eq .Values.run.workspaceType "volumeClaimTemplate" -}}
{{- if not .Values.run.pvcSize -}}
{{- fail "run.workspaceType=volumeClaimTemplate requires run.pvcSize" -}}
{{- end -}}
{{- if eq (len .Values.run.pvcAccessModes) 0 -}}
{{- fail "run.workspaceType=volumeClaimTemplate requires run.pvcAccessModes with at least one entry" -}}
{{- end -}}
{{- end -}}
