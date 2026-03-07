{{- $seen := dict -}}
{{- range $idx, $app := .Values.applications -}}
  {{- if hasKey $seen $app.name -}}
    {{- fail (printf "applications[%d].name (%s) is duplicated" $idx $app.name) -}}
  {{- end -}}
  {{- $_ := set $seen $app.name true -}}

  {{- if and $app.source.path $app.source.chart -}}
    {{- fail (printf "applications[%d].source must set either path or chart, not both" $idx) -}}
  {{- end -}}

  {{- if and (not $app.source.path) (not $app.source.chart) -}}
    {{- fail (printf "applications[%d].source must set one of: path or chart" $idx) -}}
  {{- end -}}
{{- end -}}
