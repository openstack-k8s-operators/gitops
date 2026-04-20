{{/*
Namespace for Argo CD Application CRs (metadata.namespace).
Pass root context ($) from inside range.
*/}}
{{- define "rhoso-apps.applicationNamespace" -}}
{{- default "openshift-gitops" .Values.applicationNamespace | quote -}}
{{- end }}

{{/*
Default Kubernetes API server URL for spec.destination.server.
Pass root context ($) from inside range.
*/}}
{{- define "rhoso-apps.destinationServer" -}}
{{- default "https://kubernetes.default.svc" .Values.destinationServer | quote -}}
{{- end }}

{{/*
Argo CD AppProject name; empty string in values maps to "default".
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-apps.argocdProject" -}}
{{- $app := .app -}}
{{- default "default" $app.project | quote -}}
{{- end }}

{{/*
Repository path under spec.source.path.
*/}}
{{- define "rhoso-apps.sourcePath" -}}
{{- $app := .app -}}
{{- default "." $app.path | quote -}}
{{- end }}

{{/*
Git revision, branch, or tag for spec.source.targetRevision.
*/}}
{{- define "rhoso-apps.targetRevision" -}}
{{- $app := .app -}}
{{- default "HEAD" $app.targetRevision | quote -}}
{{- end }}

{{/*
Optional spec.source.kustomize (Argo CD Kustomize overrides).
Pass dict with key "app" (per-application values map). Omitted if unset, non-map, or empty map.
*/}}
{{- define "rhoso-apps.sourceKustomize" -}}
{{- $app := .app -}}
{{- $k := $app.kustomize | default dict }}
{{- if not (kindIs "map" $k) }}
{{- $k = dict }}
{{- end }}
{{- if not (empty $k) }}
    kustomize:
{{ toYaml $k | nindent 6 }}
{{- end }}
{{- end }}

{{/*
Merge syncPolicy map with optional syncOptions; emit spec.syncPolicy block or nothing.
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-apps.syncPolicySpec" -}}
{{- $app := .app -}}
{{- $merged := $app.syncPolicy | default dict }}
{{- if not (kindIs "map" $merged) }}
{{- $merged = dict }}
{{- end }}
{{- if and $app.syncOptions (not (empty $app.syncOptions)) }}
{{- $merged = merge $merged (dict "syncOptions" $app.syncOptions) }}
{{- end }}
{{- if not (empty $merged) }}
  syncPolicy:
{{ toYaml $merged | indent 4 }}
{{- end }}
{{- end }}

{{/*
Argo CD Application metadata.finalizers (resources finalizer: background vs foreground).
Omitted finalizers default to background deletion.
Pass dict with key "app" (per-application values map).
*/}}
{{- define "rhoso-apps.applicationFinalizers" -}}
{{- $app := .app -}}
{{- $f := default (list "resources-finalizer.argocd.argoproj.io/background") $app.finalizers }}
{{- toYaml $f -}}
{{- end }}
