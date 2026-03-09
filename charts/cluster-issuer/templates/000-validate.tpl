{{- $seen := dict -}}
{{- range $idx, $resource := .Values.clusterIssuers -}}
  {{- if hasKey $seen $resource.name -}}
    {{- fail (printf "clusterIssuers[%d] duplicates name (%s)" $idx $resource.name) -}}
  {{- end -}}
  {{- $_ := set $seen $resource.name true -}}
{{- end -}}
