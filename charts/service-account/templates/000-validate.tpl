{{- $seen := dict -}}
{{- range $idx, $serviceAccount := .Values.serviceAccounts -}}
  {{- $key := printf "%s/%s" $serviceAccount.namespace $serviceAccount.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "serviceAccounts[%d] duplicates name + namespace (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}
{{- end -}}
