# Provider Adapter Guidelines

## Scope

Apply to source-control contracts, adapters, webhooks, reconciliation, and
provider-visible gates. The normative contract is
`docs/idwp-spec/006_SOURCE_CONTROL_PROVIDER_CONTRACT.md`.

## Provider Neutrality

- Domain and application policy request outcomes, never provider mechanisms.
- Provider SDK/payload types remain inside adapters.
- Missing required capabilities block production integration or enter an
  explicit documented advisory mode.
- Every externally retried write uses an idempotency key and durable evidence.

## Conformance

- Every adapter runs the same capability and behavior suite.
- Test pagination, auth failures, duplicate/reordered webhooks, retries,
  discussion lifecycle, exact-head checks, branch protection, and cleanup.
- Live writes use a dedicated sandbox identity/repository and unique run IDs.
