# CI resource review status

This branch adds explicit resource budgets to the repository-owned build path. The sizing remains provisional until representative Tekton runs are measured after cluster recovery.

Review validation: `git diff --check $(git merge-base origin/HEAD HEAD)..HEAD` passes locally. Tekton execution is intentionally deferred while cluster Kubernetes API reads are failing. A skipped or neutral PaC status is not a successful test. Before merge or rollout acceptance, run the repository pipeline individually and record duration, per-container CPU, memory and ephemeral-storage peaks, throttling, OOM/eviction and scheduling outcomes; revise budgets if measurements require it.

The final documentation commit carries `[skip tkn]` to defer this PR's automatic build. Pipeline definitions, trigger matching and security gates remain enabled.

2026-10-09 release review: tekton-ci 0.3.12 is already published, so these
resource changes publish as 0.3.13; helm-charts-ci advances to 0.1.16.
The repository's four PaC validate/publish Steps now have explicit v1
computeResources budgets. Render checks cover both supported API versions.
Budgets remain provisional pending controlled runtime sampling. [skip tkn]
