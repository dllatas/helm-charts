# Tekton Bootstrap

Bootstrap resources for this repository CI are now managed by the Helm chart:

```bash
helm upgrade --install helm-charts-ci ./charts/helm-charts-ci -n ci
```

The file `tekton-pipeline-v0.70.0-release.yaml` is kept as a pinned reference for Tekton CRD compatibility.
