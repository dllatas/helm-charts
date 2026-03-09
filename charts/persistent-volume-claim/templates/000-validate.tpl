{{- $seen := dict -}}
{{- range $idx, $claim := .Values.claims -}}
  {{- $key := printf "%s/%s" $claim.namespace $claim.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "claims[%d] duplicates name + namespace (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}
{{- end -}}
