{{- $seen := dict -}}
{{- range $idx, $resource := .Values.referenceGrants -}}
  {{- $key := printf "%s/%s" $resource.namespace $resource.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "referenceGrants[%d] duplicates name + namespace (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}
{{- end -}}
