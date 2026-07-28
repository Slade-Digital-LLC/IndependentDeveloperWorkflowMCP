# AI Coding Agent Guidelines: Testability and Automated Tests

## 1. Core Rule

Testable code and automated tests are required.

A coding task is not complete unless:

- The production code is designed for automated testing.
- All meaningful unit-testable behavior has full unit test coverage.
- Required integration tests are added or updated.
- Relevant tests are executed successfully.
- Any unexecuted or blocked tests are reported honestly.

The agent must not treat testing as optional, defer it without explicit approval, or claim success based only on compilation or code inspection.

---

## 2. Required Implementation-Plan Section

Every implementation plan that changes code must contain a section named exactly:

```markdown
## Testability and Verification
```

This section is a living record. The agent must create it before implementation begins and update it throughout the work.

It must contain the following subsections.

### 2.1 Testability Assessment

Describe how the affected code will remain or become testable.

Record:

- The business behavior being added or changed
- The external dependencies and side effects involved
- How business logic is separated from UI, framework, database, network, filesystem, queue, or scheduler code
- How time, randomness, configuration, identity, concurrency, and external services are controlled in tests
- Any required refactoring or dependency injection
- Any known testability limitations
- Any approved exception and its risk

Do not write only “code is testable.” State the actual design decisions.

### 2.2 Planned Test Coverage

Summarize the tests that will be written or changed.

The plan does not need to list every individual test case when many similar cases exist, but it must identify the meaningful behaviors and test groups.

Record:

- Unit-test classes, files, suites, or logical groups to add or update
- Integration-test classes, files, suites, or logical groups to add or update
- End-to-end tests when required
- Live API, sandbox, production-smoke, or external-database tests when required
- Regression tests for defects
- Normal, boundary, invalid, duplicate, retry, concurrency, and failure cases that must be covered
- Existing tests expected to protect unchanged behavior
- Tests intentionally not added and the reason

Use concrete descriptions, for example:

```text
OrderServiceTests
- Successful order placement
- Rejected payment
- Duplicate idempotency key
- Inventory failure rollback
- Boundary values for quantity and price

OrderRepositoryIntegrationTests
- Insert and reload
- Transaction rollback
- Unique-constraint behavior
```

### 2.3 Database, Resource, and Parallelism Strategy

When tests use a database, external service, filesystem, fixed port, queue, shared cache, or other mutable resource, record:

- Whether the resource is mocked, local, sandbox, shared, or live
- How test state is created
- How mutable state is isolated or reset
- Cleanup behavior
- Unique test identifiers or namespaces
- Transaction, schema, database, container, or worker isolation strategy
- Which tests may run in parallel
- Which tests must run sequentially
- Any resource locks or test collections
- Whether explicit ordering is required and why

Ordinary tests must not depend on execution order.

If ordering is required because the sequence itself is under test, state that explicitly.

### 2.4 Live Verification Strategy

When the affected code integrates with a real API or independently managed database, record:

- The live target or environment
- Whether access is read-only or writable
- The specific contract or behavior being verified
- Required credentials, permissions, or scopes
- Safety controls for writes
- Idempotency and cleanup strategy
- Stable invariants or sentinel records used
- Expected nondeterministic failure modes
- Retry policy, if any
- Whether the live test is blocking, scheduled, post-deployment, or informational

Normal unit-test execution must not unexpectedly contact a live system.

### 2.5 Implementation Checklist

The plan must include and maintain this checklist:

```markdown
### Testability and Verification Checklist

- [ ] Identify all new or changed behaviors.
- [ ] Identify business logic, side effects, and external dependencies.
- [ ] Confirm business logic is separated from UI, framework, database, and network code.
- [ ] Confirm time, randomness, configuration, concurrency, and external services are controllable in tests.
- [ ] Define the required unit tests.
- [ ] Define the required integration tests.
- [ ] Define whether live API or live external-database tests are required.
- [ ] Define database isolation, cleanup, ordering, and parallel-execution rules.
- [ ] Add or update tests before or alongside the implementation.
- [ ] Cover normal, boundary, invalid, duplicate, and failure cases.
- [ ] Add a regression test for every fixed defect when practical.
- [ ] Run focused tests for the changed behavior.
- [ ] Run the broader relevant test suite.
- [ ] Run coverage tooling when available and review uncovered meaningful behavior.
- [ ] Confirm no flaky, order-dependent, or environment-dependent tests were introduced.
- [ ] Report exactly which tests passed, failed, were blocked, or were not run.
```

If an item does not apply, mark it complete and state why.

### 2.6 Tests Added, Changed, or Relied Upon

As implementation proceeds, record the tests that were added, changed, removed, or materially relied upon for the current change.

Do not list every unchanged test in the repository.

Include, at the appropriate level of detail:

- Test file, class, suite, or logical group
- Whether the test was added, changed, removed, or relied upon unchanged
- Behavior protected
- Important cases covered
- Whether it is unit, integration, end-to-end, or live
- Any unusual fixture, mock, fake, seed data, shared resource, or setup
- Any test removed or replaced and why
- Any existing failing test discovered
- Any test that remains flaky, quarantined, skipped, or disabled
- Any follow-up testing debt

Unchanged tests should be mentioned only when they materially protect the affected code path or explain why no new test was necessary.

For large test suites, summarize at the class, suite, feature, or logical-group level rather than listing every individual test.

Example:

```text
Added:
- OrderServiceTests
  - Covers rejected payments, duplicate idempotency keys, and inventory rollback.

Changed:
- OrderRepositoryIntegrationTests
  - Updated expected persistence behavior for the new status field.

Relied upon unchanged:
- OrderPricingTests
  - Existing parameterized coverage already protects all unchanged pricing rules.

Removed:
- LegacyOrderMappingTests
  - Replaced by OrderMapperContractTests after removal of the legacy mapper.
```

This section should help a future agent understand the safety net around the changed behavior without becoming an inventory of the entire test suite.

### 2.7 Validation Results

Record each executed validation command and its result.

Include:

- Exact command
- Working directory when relevant
- Test category or scope
- Pass, fail, blocked, or not-run status
- Number of tests when available
- Failures encountered
- Fixes made
- Final rerun result
- Coverage result when available
- Build, analyzer, warning, package, lint, or formatting results when relevant
- Live verification result when applicable

Do not report a test as passed unless it was executed successfully.

### 2.8 Coverage and Remaining Risk

At completion, summarize:

- What behavior is covered by unit tests
- What behavior is covered only by integration, end-to-end, or live tests
- Important uncovered behavior
- Environmental assumptions
- Remaining nondeterminism
- Known limitations
- Approved exceptions
- Recommended future tests or refactoring

“100% coverage” alone is not an adequate summary. State what meaningful behavior is protected.

### 2.9 Final Verification Status

End the section with a concise final status using these terms:

```text
Passed:
    Executed and succeeded.

Failed:
    Executed and failed.

Blocked:
    Could not run because a required dependency or environment was unavailable.

Not run:
    Was not executed.

Inferred:
    Appears correct by inspection but was not verified.
```

The final status must identify:

- Focused tests
- Broader regression suite
- Integration tests
- Coverage
- Live verification
- Any remaining blocked or unverified area

### 2.10 Required Section Template

Use this structure in the implementation plan:

```markdown
## Testability and Verification

### Testability Assessment
<Design decisions, dependencies, side effects, and testability notes>

### Planned Test Coverage
<Unit, integration, end-to-end, live, regression, boundary, and failure coverage>

### Database, Resource, and Parallelism Strategy
<Isolation, cleanup, shared resources, ordering, locks, and parallelism>

### Live Verification Strategy
<Live targets, contracts, safety controls, credentials, retries, and applicability>

### Testability and Verification Checklist
- [ ] Identify all new or changed behaviors.
- [ ] Identify business logic, side effects, and external dependencies.
- [ ] Confirm business logic is separated from UI, framework, database, and network code.
- [ ] Confirm time, randomness, configuration, concurrency, and external services are controllable in tests.
- [ ] Define the required unit tests.
- [ ] Define the required integration tests.
- [ ] Define whether live API or live external-database tests are required.
- [ ] Define database isolation, cleanup, ordering, and parallel-execution rules.
- [ ] Add or update tests before or alongside the implementation.
- [ ] Cover normal, boundary, invalid, duplicate, and failure cases.
- [ ] Add a regression test for every fixed defect when practical.
- [ ] Run focused tests for the changed behavior.
- [ ] Run the broader relevant test suite.
- [ ] Run coverage tooling when available and review uncovered meaningful behavior.
- [ ] Confirm no flaky, order-dependent, or environment-dependent tests were introduced.
- [ ] Report exactly which tests passed, failed, were blocked, or were not run.

### Tests Added, Changed, or Relied Upon
<Relevant test files or logical groups, whether added/changed/removed/relied upon, behaviors covered, notable fixtures, and testing debt>

### Validation Results
| Command | Scope | Result | Notes |
|---|---|---|---|
| `<command>` | `<unit/integration/build/live/etc.>` | `<Passed/Failed/Blocked/Not run>` | `<details>` |

### Coverage and Remaining Risk
<Meaningful coverage, uncovered behavior, assumptions, limitations, and follow-up work>

### Final Verification Status
- Focused tests: <status and summary>
- Broader regression suite: <status and summary>
- Integration tests: <status and summary>
- Coverage: <status and summary>
- Live verification: <status and summary>
- Remaining unverified areas: <none or details>
```


---

## 3. Definition of Done

A task is complete only when:

1. The requested behavior is implemented.
2. The code is testable.
3. Unit tests cover all meaningful unit-testable behavior.
4. Integration tests cover database, framework, file, queue, or external-boundary behavior where needed.
5. Important normal, boundary, invalid, duplicate, and failure cases are tested.
6. Relevant tests pass.
7. Existing behavior remains protected.
8. No flaky or accidental order dependency is introduced.
9. Testing limitations are disclosed.

---

## 4. Design for Testability

Business behavior must be testable without requiring the full application.

Where practical, tests must not require:

- A user interface
- A running web server
- A production database
- A live external API
- Real email or payment processing
- Uncontrolled system time
- Uncontrolled randomness
- Arbitrary sleeps
- Developer-specific configuration

### Required design rules

- Separate business logic from controllers, UI handlers, database access, HTTP clients, and framework callbacks.
- Inject external dependencies rather than constructing them inside business classes.
- Treat time, randomness, configuration, persistence, networking, and concurrency as explicit dependencies.
- Prefer pure functions and explicit inputs and outputs.
- Avoid global mutable state and service locators.
- Keep constructors free of network calls, database access, thread creation, and business workflows.
- Wrap third-party SDKs behind application-owned interfaces when practical.
- Make side effects explicit and observable.
- Do not make private methods public only for testing. Extract important logic into a proper testable component.

---

## 5. Unit Test Requirements

Full unit test coverage of meaningful unit-testable behavior is required.

Unit tests must cover applicable:

- Business rules
- Calculations
- Validation
- Conditional branches
- State transitions
- Parsing and mapping
- Authorization decisions
- Error handling
- Retry and idempotency logic
- Time-sensitive behavior
- Boundary conditions

For each behavior, consider:

- Normal input
- Empty or missing input
- Null input where valid
- Invalid input
- Minimum and maximum values
- Values immediately before and after boundaries
- Duplicate or repeated operations
- Dependency failures
- Exception paths

Coverage percentages are diagnostic only. Executing a line is not the same as testing behavior.

Tests must contain meaningful assertions.

---

## 6. Test Structure

Tests should:

- Follow Arrange, Act, Assert.
- Verify observable behavior, not internal implementation.
- Have descriptive names stating condition and expected result.
- Test one meaningful behavior per test.
- Be deterministic and independent.
- Use real domain objects where practical.
- Use mocks primarily at external boundaries.
- Avoid excessive interaction verification.
- Avoid arbitrary sleeps.
- Fail with useful diagnostic information.

A test must not depend on another ordinary test running first.

If several ordered steps form one workflow, write one scenario test.

---

## 7. Testing Layers

Use the smallest appropriate test type.

### Unit tests

Use for business rules, calculations, validation, state transitions, parsing, and decisions.

### Integration tests

Use for:

- Databases
- Transactions
- Migrations
- Serialization
- Files
- HTTP adapters
- Queues
- Framework wiring
- Component collaboration

### End-to-end tests

Use sparingly for critical complete workflows.

End-to-end tests do not replace unit tests.

### Live tests

Use when mocks or local substitutes cannot prove that the real dependency works.

Examples:

- Third-party APIs
- Vendor sandboxes
- Authentication services
- Read-only production APIs
- Live external or immutable databases
- Production smoke checks

Live tests complement deterministic tests. They do not replace them.

---

## 8. Database Test Rules

Reusing database infrastructure is allowed.

Reusing uncontrolled mutable test state is not.

Acceptable isolation methods include:

1. Transaction per test with rollback
2. Database reset between tests
3. Schema per test
4. Database per test
5. Database or schema per parallel worker

### Shared test database rules

When tests share a database:

- Mutable state must be reset or isolated.
- Test data must use unique identifiers.
- Shared reference data must be immutable.
- Conflicting tests must not run in parallel.
- Sequential-only groups must be explicit.
- One database per parallel worker is preferred when practical.

### Sequential versus ordered

Sequential means tests do not overlap.

Ordered means one test depends on another.

Sequential execution may be acceptable for a shared resource.

Ordered ordinary tests are prohibited.

Explicit ordering is allowed only when the sequence itself is under test, such as migrations or stateful workflow validation.

---

## 9. Parallel Execution

The agent must define parallelism deliberately.

Example:

```text
Unit tests:
    Fully parallel

Isolated database-worker tests:
    Parallel across workers

Single shared mutable database tests:
    Sequential

Fixed-port or shared-file tests:
    Protected by resource locks

End-to-end tests:
    Limited parallelism
```

Do not disable all parallelism merely to hide test interference.

Do not enable parallelism without confirming isolation.

---

## 10. Live API and External Database Tests

Mocks prove behavior against assumptions.

Live tests prove that selected assumptions still match reality.

Live tests may verify:

- Connectivity
- DNS and TLS
- Authentication and authorization
- Required scopes
- Request and response compatibility
- Real serialization
- Pagination
- Provider error formats
- Schema compatibility
- Deployment configuration

Live external-database tests may verify:

- Connection success
- Required schemas, tables, views, and columns
- Compatible data types
- Query validity
- Stable invariants
- Real-row mapping

Prefer schema and invariant checks over fragile row counts or timestamps.

Live tests must be tagged and separated from the normal unit-test run.

Examples:

```text
live
external
sandbox
production-smoke
```

Normal local tests must not unexpectedly call production systems.

---

## 11. Live Write Tests

Use this order of preference:

1. Local emulator
2. Provider sandbox
3. Dedicated test tenant
4. Dedicated test account
5. Reversible production operation
6. Production write only when strictly necessary

Live write tests must use:

- Dedicated least-privilege credentials
- Unique run identifiers
- Clearly marked test data
- Idempotency keys where supported
- Explicit cleanup
- Orphan cleanup procedures
- Safe limits

The agent must not create tests that can accidentally charge real cards, contact customers, create real orders, alter accounting records, reserve inventory, or trigger irreversible workflows without explicit authorization.

---

## 12. Retries and Flaky Tests

Retries are allowed only for known transient failures such as:

- Connection reset
- HTTP 502, 503, or 504
- Temporary DNS failure
- Rate limiting with Retry-After

Do not retry:

- Assertion failures
- Schema mismatches
- Missing fields
- Authorization failures
- Invalid mappings
- Business-rule failures

Retries must be bounded and visible.

Flaky tests are defects.

The agent must not rerun a failing test until it passes and then declare success.

---

## 13. Regression Tests

Every reproducible bug fix should include a regression test when practical.

Preferred workflow:

1. Write a test that reproduces the defect.
2. Confirm it fails.
3. Apply the fix.
4. Confirm it passes.
5. Run surrounding tests.

Untested legacy code does not justify adding more untested behavior.

Changed and newly introduced behavior must receive full unit test coverage.

---

## 14. Test Execution and Reporting

Before finishing, run the relevant available:

- Unit tests
- Integration tests
- Build
- Static analysis
- Formatting or lint checks
- Coverage command
- Live or sandbox tests when required and available

The agent must never claim a test passed unless it was executed successfully.

Final reporting must distinguish:

```text
Passed:
    Executed and succeeded.

Failed:
    Executed and failed.

Blocked:
    Could not run because a dependency or environment was unavailable.

Not run:
    Was not executed.

Inferred:
    Appears correct by inspection but was not verified.
```

For blocked or unexecuted tests, report:

- What was not run
- Why
- What remains unverified
- The command to run where practical

---

## 15. Prohibited Shortcuts

The agent must not:

- Skip tests because a change appears small.
- Treat testability as optional.
- Place business rules in UI or infrastructure code for convenience.
- Depend on ordinary test execution order.
- Share uncontrolled mutable test state.
- Disable valid tests to make a build pass.
- Remove meaningful assertions without justification.
- Add superficial tests solely to raise coverage.
- Hide instability with retries or sleeps.
- Call production services from normal unit tests.
- Store live credentials in source code.
- Claim verification without execution.

---

## 16. Exceptions

Exceptions require explicit justification.

An exception is allowed only when automated testing is technically infeasible, grossly disproportionate to the risk, or explicitly waived by the user.

Document:

- The untested behavior
- Why it was not tested
- The risk
- Any manual or operational verification
- Recommended future remediation

Exceptions must be narrow and do not remove the requirement to test all remaining testable behavior.

---

## 17. Final Standard

The agent must follow these principles:

> Production code must be designed for automated verification.

> All meaningful unit-testable behavior must receive full unit test coverage.

> Database, framework, and external-boundary behavior must receive focused integration tests where appropriate.

> Live tests must be used when only the real dependency can validate the integration.

> Testing results must be reported honestly and precisely.
