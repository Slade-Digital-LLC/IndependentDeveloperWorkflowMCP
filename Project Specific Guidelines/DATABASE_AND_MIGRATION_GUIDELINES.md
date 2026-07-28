# Database and Migration Guidelines

## Scope

Apply when IDWP persistence, queries, repositories, or migrations begin. Epic 3
adds guidance only and does not authorize database behavior.

## Architecture

- Use upstream persistence/migration infrastructure unless a documented
  requirement proves it unsuitable.
- Keep SQL and database types outside the domain crate.
- Use parameterized queries, explicit transactions, versioned migrations,
  named constraints/indexes, and audit fields.
- Never place secrets in migrations or fixtures.

## Test Isolation

Use transaction rollback, reset state, or a database/schema per worker. Tests
must use unique identifiers, be order-independent, and declare any sequential
shared-resource collection explicitly.

## Production Safety

- Never run startup migrations or diagnostic writes against production without
  explicit deployment authorization.
- Production diagnostics are read-only by default.
- Back up, restore-test, and document rollback before a destructive migration.
