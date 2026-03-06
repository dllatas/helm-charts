{{- $mode := .Values.eventListener.mode -}}
{{- if not (or (eq $mode "single") (eq $mode "perTrigger")) -}}
{{- fail (printf "eventListener.mode must be one of [single, perTrigger], got %q" $mode) -}}
{{- end -}}

{{- $triggerNames := dict -}}
{{- range $trigger := .Values.triggers -}}
{{- if hasKey $triggerNames $trigger.name -}}
{{- fail (printf "duplicate trigger name %q in triggers[]" $trigger.name) -}}
{{- end -}}
{{- $_ := set $triggerNames $trigger.name true -}}

{{- if not $trigger.repoFullName -}}
{{- fail (printf "trigger %q requires repoFullName" $trigger.name) -}}
{{- end -}}
{{- if not $trigger.image.reference -}}
{{- fail (printf "trigger %q requires image.reference" $trigger.name) -}}
{{- end -}}
{{- if not $trigger.image.dockerfile -}}
{{- fail (printf "trigger %q requires image.dockerfile" $trigger.name) -}}
{{- end -}}
{{- if not $trigger.image.context -}}
{{- fail (printf "trigger %q requires image.context" $trigger.name) -}}
{{- end -}}
{{- if eq (len $trigger.pathFilters) 0 -}}
{{- fail (printf "trigger %q requires at least one pathFilters entry" $trigger.name) -}}
{{- end -}}
{{- end -}}

{{- if and .Values.httpRoute.enabled (eq (len .Values.httpRoute.parentRefs) 0) -}}
{{- fail "httpRoute.enabled=true requires httpRoute.parentRefs with at least one entry" -}}
{{- end -}}

{{- if and .Values.httpRoute.enabled (eq $mode "single") (not .Values.httpRoute.pathPrefix) -}}
{{- fail "httpRoute.pathPrefix must be set when eventListener.mode=single" -}}
{{- end -}}

{{- if and (not .Values.triggerBinding.create) (not .Values.triggerBinding.name) -}}
{{- fail "triggerBinding.create=false requires triggerBinding.name" -}}
{{- end -}}

{{- if and (not .Values.triggerTemplate.create) (not .Values.triggerTemplate.name) -}}
{{- fail "triggerTemplate.create=false requires triggerTemplate.name" -}}
{{- end -}}

{{- if eq $mode "perTrigger" -}}
{{- $pathMap := dict -}}
{{- range $trigger := .Values.triggers -}}
{{- $routePath := include "tekton-ci.triggerRoutePath" (dict "root" $ "trigger" $trigger) -}}
{{- if hasKey $pathMap $routePath -}}
{{- fail (printf "duplicate resolved route path %q for triggers %q and %q" $routePath (get $pathMap $routePath) $trigger.name) -}}
{{- end -}}
{{- $_ := set $pathMap $routePath $trigger.name -}}
{{- end -}}
{{- end -}}

{{- range $key, $_ := .Values.httpRoute.routePathPrefixByTrigger -}}
{{- if not (hasKey $triggerNames $key) -}}
{{- fail (printf "httpRoute.routePathPrefixByTrigger references unknown trigger %q" $key) -}}
{{- end -}}
{{- end -}}
