{{- if or (eq .Values.name "default") (eq .Values.name "kube-system") (eq .Values.name "kube-public") -}}
{{- fail (printf "name (%s) is a protected built-in namespace" .Values.name) -}}
{{- end -}}
