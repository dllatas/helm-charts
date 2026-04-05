# Tekton Reference

This repo's active CI now lives in `.tekton/` as Pipelines as Code `PipelineRun` definitions that execute in namespace `ci`.

The legacy cluster-managed bootstrap resources for this repo are still available via the Helm chart:

```bash
helm upgrade --install helm-charts-ci ./charts/helm-charts-ci -n ci
```

The file `tekton-pipeline-v0.70.0-release.yaml` is kept only as a pinned reference for Tekton CRD compatibility and legacy bootstrap/e2e work.
