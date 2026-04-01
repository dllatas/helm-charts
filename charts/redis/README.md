# redis chart

Redis Helm v4 chart for running a primary instance with optional replicas.

## Scope

- Creates namespaced resources only.
- Uses StatefulSets for both the primary and replica roles.
- Supports persistent or ephemeral storage for each role.
- Supports optional password authentication via generated or existing Secret.

## Rendered resources

- `ServiceAccount` when `serviceAccount.create` is enabled.
- `Secret` when `auth.enabled` is true and `auth.existingSecret` is not set.
- Headless and client `Service` resources for the primary role.
- Headless and client `Service` resources for the replica role when replicas are enabled.
- One primary `StatefulSet`.
- One replica `StatefulSet` when `replica.replicaCount > 0`.

## Values contract

Top-level:

- `image`: Redis container image settings.
- `auth`: optional password authentication settings.
- `redis`: Redis port and runtime argument settings.
- `primary`: primary StatefulSet settings.
- `replica`: replica StatefulSet settings.

## Validation guards

Template-time `fail` checks reject invalid authentication combinations:

- `auth.enabled: true` requires either `auth.password` or `auth.existingSecret`.
- `auth.password` and `auth.existingSecret` cannot be set together.
- `auth.existingSecretPasswordKey` must be set when `auth.existingSecret` is used.

## Examples

- `examples/minimal.yaml`
- `examples/auth.yaml`
- `examples/ephemeral.yaml`
- `examples/invalid-auth.yaml`

## OpenTelemetry Collector integration

This chart does not make Redis emit OTLP metrics by itself. Instead, an OpenTelemetry Collector can connect to Redis with the `redisreceiver`, run Redis `INFO` commands on an interval, and convert that data into OpenTelemetry metrics.

That is the relevant model for this chart when you already run a cluster-level Collector:

1. Redis runs inside the cluster.
2. The OpenTelemetry Collector connects to Redis over the network.
3. The Collector scrapes Redis server metrics with `redisreceiver`.
4. The Collector exports those metrics to your metrics backend.
5. Grafana reads from that backend.

### Does this end up in Prometheus and Grafana?

Yes, if your Collector is configured that way.

The important detail is that the Collector does not store metrics itself. It collects and forwards them. In a common setup:

- the Collector scrapes Redis with `redisreceiver`
- the Collector exports metrics to Prometheus, or to a Prometheus-compatible backend
- Grafana queries Prometheus or that backend

So the practical flow is:

```text
Redis -> OpenTelemetry Collector -> Prometheus-compatible metrics backend -> Grafana
```

Depending on your observability stack, the Collector usually does one of these:

- exposes metrics for Prometheus to scrape
- remote-writes metrics to a Prometheus-compatible backend
- exports metrics to another OTEL-native backend

### Endpoints exposed by this chart

The chart creates stable endpoints that a Collector can target.

Primary:

- client service: `<release>-primary.<namespace>.svc.cluster.local:6379`
- headless service: `<release>-primary-headless.<namespace>.svc.cluster.local:6379`
- primary pod: `<release>-primary-0.<release>-primary-headless.<namespace>.svc.cluster.local:6379`

Replicas when `replica.replicaCount > 0`:

- client service: `<release>-replica.<namespace>.svc.cluster.local:6379`
- headless service: `<release>-replica-headless.<namespace>.svc.cluster.local:6379`
- per-pod stable DNS:
  - `<release>-replica-0.<release>-replica-headless.<namespace>.svc.cluster.local:6379`
  - `<release>-replica-1.<release>-replica-headless.<namespace>.svc.cluster.local:6379`
  - and so on

### Recommended target choice

For the primary, use the primary Service or the primary pod DNS name.

For replicas, prefer the per-pod DNS names from the replica StatefulSet.

Do not rely on the replica client Service if you want metrics for every replica. That Service load-balances across replica pods, so a Collector scraping the Service address will only talk to one backend per scrape. The `redisreceiver` does not discover all replica pods automatically.

### Example Collector configuration

Minimal example for a release named `redis-prod` in namespace `data`:

```yaml
receivers:
  redis/primary:
    endpoint: redis-prod-primary.data.svc.cluster.local:6379
    collection_interval: 10s

  redis/replica-0:
    endpoint: redis-prod-replica-0.redis-prod-replica-headless.data.svc.cluster.local:6379
    collection_interval: 10s

  redis/replica-1:
    endpoint: redis-prod-replica-1.redis-prod-replica-headless.data.svc.cluster.local:6379
    collection_interval: 10s

service:
  pipelines:
    metrics:
      receivers:
        - redis/primary
        - redis/replica-0
        - redis/replica-1
```

If you scale replicas up or down, update the Collector configuration to match. The receiver expects explicit endpoints.

### Example with password authentication enabled

If this chart uses password auth, the Collector must also authenticate to Redis.

Example pattern:

```yaml
receivers:
  redis/primary:
    endpoint: redis-prod-primary.data.svc.cluster.local:6379
    collection_interval: 10s
    password: ${env:REDIS_PASSWORD}

  redis/replica-0:
    endpoint: redis-prod-replica-0.redis-prod-replica-headless.data.svc.cluster.local:6379
    collection_interval: 10s
    password: ${env:REDIS_PASSWORD}
```

In that setup, the Collector deployment needs access to the same Redis password through an environment variable or another secret mechanism supported by your Collector deployment pattern.

### Why this chart does not configure the Collector for you

The receiver configuration belongs to the OpenTelemetry Collector, not to Redis itself.

Keeping that config outside this chart is usually the cleaner design because:

- one Collector often scrapes many workloads
- receiver definitions depend on your shared observability topology
- exporter choice is cluster-specific
- secret handling for Collector credentials is usually centralized

This chart therefore focuses on exposing stable Redis endpoints and leaves Collector pipeline wiring to your observability stack.

### Operational notes

- The Collector must have network access to the Redis Services or pod DNS names.
- If auth is enabled, the Collector needs the Redis password.
- The Collector user or password must be allowed to run `INFO` and `PING`.
- If you use per-pod replica endpoints, remember to update Collector config when replica counts change.
- For dashboards, confirm whether your metrics backend keeps the receiver name or endpoint as a resource attribute so primary and replica series stay distinguishable.
