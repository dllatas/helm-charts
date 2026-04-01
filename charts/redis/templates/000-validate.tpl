{{- if and .Values.auth.enabled .Values.auth.password .Values.auth.existingSecret -}}
{{- fail "auth.password and auth.existingSecret cannot be set together when auth.enabled is true" -}}
{{- end -}}

{{- if and .Values.auth.enabled (not .Values.auth.password) (not .Values.auth.existingSecret) -}}
{{- fail "auth.enabled requires either auth.password or auth.existingSecret" -}}
{{- end -}}

{{- if and .Values.auth.enabled .Values.auth.existingSecret (not .Values.auth.existingSecretPasswordKey) -}}
{{- fail "auth.existingSecretPasswordKey must be set when auth.existingSecret is used" -}}
{{- end -}}
