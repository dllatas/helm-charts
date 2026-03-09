# TODO

## CI

- Improve chart version gating so branch and PR validation compare changed charts against the target branch or merge-base, not only the previous branch push. That should surface missing version bumps for existing charts before merge-to-master.
- Fix slash-named branch parsing in `charts/helm-charts-ci/templates/event-listener.yaml`; `body.ref.split('/')[2]` truncates branches like `codex/foo`.
