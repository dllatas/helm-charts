{{- $seen := dict -}}
{{- range $idx, $externalSecret := .Values.externalSecrets -}}
  {{- $namespace := default $.Values.defaults.namespace $externalSecret.namespace -}}
  {{- if not $namespace -}}
    {{- fail (printf "externalSecrets[%d] must set namespace or define defaults.namespace" $idx) -}}
  {{- end -}}
  {{- $defaultStore := default (dict) $.Values.defaults.secretStoreRef -}}
  {{- $secretStoreRef := mergeOverwrite (dict) $defaultStore (default (dict) $externalSecret.secretStoreRef) -}}
  {{- $storeKind := $secretStoreRef.kind -}}
  {{- $storeName := $secretStoreRef.name -}}
  {{- if or (not $storeKind) (not $storeName) -}}
    {{- fail (printf "externalSecrets[%d] must set secretStoreRef or define defaults.secretStoreRef" $idx) -}}
  {{- end -}}
  {{- $key := printf "%s/%s" $namespace $externalSecret.name -}}
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
