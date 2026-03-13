#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

helm template application-exact charts/application -f charts/application/examples/exact-names.yaml >"$tmpdir/exact.yaml"

grep -q '^kind: Deployment$' "$tmpdir/exact.yaml"
grep -q '^  name: example-api$' "$tmpdir/exact.yaml"
grep -q '^kind: Service$' "$tmpdir/exact.yaml"
grep -q '^  name: example-api$' "$tmpdir/exact.yaml"
grep -q '^kind: HTTPRoute$' "$tmpdir/exact.yaml"
grep -q '^    argocd.argoproj.io/sync-wave: "20"$' "$tmpdir/exact.yaml"
grep -q '^        - name: example-api$' "$tmpdir/exact.yaml"
grep -q '^kind: PersistentVolumeClaim$' "$tmpdir/exact.yaml"
grep -q '^  name: data$' "$tmpdir/exact.yaml"
grep -q '^      app: example-api$' "$tmpdir/exact.yaml"
grep -q '^  strategy:$' "$tmpdir/exact.yaml"
grep -q '^    type: Recreate$' "$tmpdir/exact.yaml"
grep -q '^      serviceAccountName: example-api$' "$tmpdir/exact.yaml"
grep -q '^      nodeSelector:$' "$tmpdir/exact.yaml"
grep -q '^        harokilabs.com/capacity-class: general$' "$tmpdir/exact.yaml"
grep -q '^      affinity:$' "$tmpdir/exact.yaml"
grep -q 'topologyKey: kubernetes.io/hostname' "$tmpdir/exact.yaml"

echo "application render tests passed"
