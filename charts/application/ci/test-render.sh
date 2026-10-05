#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

helm template application-exact charts/application -f charts/application/examples/exact-names.yaml >"$tmpdir/exact.yaml"
helm template application-minimal charts/application -f charts/application/examples/minimal.yaml >"$tmpdir/minimal.yaml"

if grep -Eq '^      (affinity|topologySpreadConstraints):' "$tmpdir/minimal.yaml"; then
  echo "unset scheduling values should not render" >&2
  exit 1
fi

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
grep -q '^      topologySpreadConstraints:$' "$tmpdir/exact.yaml"
grep -q '^          whenUnsatisfiable: ScheduleAnyway$' "$tmpdir/exact.yaml"

cat >"$tmpdir/anti-affinity.yaml" <<'EOF'
containers:
  - name: app
    image: nginx:1.27.4
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: kubernetes.io/hostname
        labelSelector:
          matchLabels:
            app: example
EOF
helm template application-anti-affinity charts/application -f "$tmpdir/anti-affinity.yaml" >"$tmpdir/anti-affinity-rendered.yaml"
grep -q '^      affinity:$' "$tmpdir/anti-affinity-rendered.yaml"
grep -q '^        podAntiAffinity:$' "$tmpdir/anti-affinity-rendered.yaml"
if grep -q '^      topologySpreadConstraints:' "$tmpdir/anti-affinity-rendered.yaml"; then
  echo "empty topologySpreadConstraints should not render" >&2
  exit 1
fi

echo "application render tests passed"
