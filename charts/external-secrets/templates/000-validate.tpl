{{- $seen := dict -}}
{{- range $idx, $externalSecret := .Values.externalSecrets -}}
  {{- $key := printf "%s/%s" $externalSecret.namespace $externalSecret.name -}}
  {{- if hasKey $seen $key -}}
    {{- fail (printf "externalSecrets[%d] duplicates name + namespace (%s)" $idx $key) -}}
  {{- end -}}
  {{- $_ := set $seen $key true -}}

  {{- $hasData := gt (len (default (list) $externalSecret.data)) 0 -}}
  {{- $hasDataFrom := gt (len (default (list) $externalSecret.dataFrom)) 0 -}}
  {{- if and $hasData $hasDataFrom -}}
    {{- fail (printf "externalSecrets[%d] must set exactly one of data or dataFrom" $idx) -}}
  {{- end -}}
  {{- if and (not $hasData) (not $hasDataFrom) -}}
    {{- fail (printf "externalSecrets[%d] must set one of: data or dataFrom" $idx) -}}
  {{- end -}}
{{- end -}}
