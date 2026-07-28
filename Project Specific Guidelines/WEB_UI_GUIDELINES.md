# IDWP Web UI Guidelines

## Scope

Apply to IDWP extensions of the upstream Svelte dashboard. Do not replace the
upstream framework solely to match reusable stack-specific guidance.

## Accessibility

Meet WCAG 2.2 AA with semantic controls, labels, keyboard operation, visible
focus, accessible errors/status updates, non-color-only meaning, and equivalent
tables for charts.

## Behavior

Use upstream design conventions, prevent duplicate submissions, show bounded
loading states, preserve detailed safe errors, and keep authorization enforced
server-side.

## Testing

Unit-test deterministic presentation logic and use browser tests for keyboard,
focus, dynamic updates, validation, loading, and accessibility. UI tests do not
replace application/domain tests.
