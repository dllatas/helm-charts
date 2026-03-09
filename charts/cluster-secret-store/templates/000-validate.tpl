{{- $seen := dict -}}
{{- range $idx, $resource := .Values.clusterSecretStores -}}
  {{- if hasKey $seen $resource.name -}}
    {{- fail (printf "clusterSecretStores[%d] duplicates name (%s)" $idx $resource.name) -}}
  {{- end -}}
  {{- $_ := set $seen $resource.name true -}}
{{- end -}}
