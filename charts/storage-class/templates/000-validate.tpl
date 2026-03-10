{{- $seen := dict -}}
{{- range $idx, $resource := .Values.storageClasses -}}
  {{- $key := $resource.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "storageClasses[%d] duplicates name (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}
{{- end -}}
