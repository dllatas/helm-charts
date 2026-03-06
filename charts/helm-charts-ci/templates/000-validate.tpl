{{- if not .Values.github.repositoryFullName -}}
{{- fail "github.repositoryFullName must be set" -}}
{{- end -}}
{{- if and .Values.httpRoute.enabled (eq (len .Values.httpRoute.parentRefs) 0) -}}
{{- fail "httpRoute.enabled=true requires httpRoute.parentRefs with at least one entry" -}}
{{- end -}}
{{- if and .Values.httpRoute.enabled (not .Values.httpRoute.pathPrefix) -}}
{{- fail "httpRoute.enabled=true requires httpRoute.pathPrefix" -}}
{{- end -}}
