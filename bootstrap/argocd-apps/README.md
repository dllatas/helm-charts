# Argo CD bootstrap values

This directory keeps one `argocd-apps` values file per Argo CD `Application`.

Current Phase 1 apps:

- `kubescape.yaml`: installs the upstream Kubescape operator chart into the `kubescape` namespace.
- `agent-evals.yaml`: installs the upstream `agentevals` Helm chart into the `agent-evals` namespace.

Each values file has a sibling `.lock.yaml` file for the Tekton inline deploy flow documented in `charts/tekton-ci/README.md`.

The `agent-evals` app is intentionally minimal because the upstream chart currently focuses on the core service, UI, OTLP receiver, and MCP endpoint. You still need to decide how you want to expose and wire it in your cluster:

- ingress or Gateway API route for the UI and API
- OTel exporters from the agents you want to evaluate
- provider API keys via a Kubernetes `Secret` or `ExternalSecret` when you use LLM-based evaluators
