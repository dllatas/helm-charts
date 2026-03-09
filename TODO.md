# TODO

## CI

- Improve chart version gating so branch and PR validation compare changed charts against the target branch or merge-base, not only the previous branch push. That should surface missing version bumps for existing charts before merge-to-master.
- Fix slash-named branch parsing in `charts/helm-charts-ci/templates/event-listener.yaml`; `body.ref.split('/')[2]` truncates branches like `codex/foo`.
- After `helm-charts-ci 0.1.11` is published, bump the ArgoCD-managed bootstrap app in `netcup-apps` to `0.1.11` and sync it. Otherwise the cluster will keep running the older pipeline logic.
