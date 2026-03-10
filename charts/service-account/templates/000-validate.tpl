{{- $seen := dict -}}
{{- range $idx, $serviceAccount := .Values.serviceAccounts -}}
  {{- $namespace := default $.Values.defaults.namespace $serviceAccount.namespace -}}
  {{- if not $namespace -}}
    {{- fail (printf "serviceAccounts[%d] must set namespace or define defaults.namespace" $idx) -}}
  {{- end -}}
  {{- $key := printf "%s/%s" $namespace $serviceAccount.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "serviceAccounts[%d] duplicates name + namespace (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}
{{- end -}}
