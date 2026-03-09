{{- $seen := dict -}}
{{- range $idx, $resource := .Values.clusterRoleBindings -}}
  {{- $key := $resource.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "clusterRoleBindings[%d] duplicates name (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}
{{- end -}}
