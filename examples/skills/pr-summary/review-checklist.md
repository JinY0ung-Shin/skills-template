# Review Checklist

Use this checklist when reviewing PRs. Not all items apply to every PR.

## Code Quality
- [ ] No dead code or commented-out blocks
- [ ] Functions are focused and reasonably sized
- [ ] Naming is clear and consistent with codebase conventions
- [ ] No duplicated logic that should be extracted

## Correctness
- [ ] Edge cases are handled (null, empty, boundary values)
- [ ] Error handling is appropriate (not swallowed, not overly broad)
- [ ] Concurrent access is safe (if applicable)
- [ ] Database migrations are reversible (if applicable)

## Security
- [ ] No secrets or credentials in code
- [ ] User input is validated and sanitized
- [ ] SQL queries use parameterized statements
- [ ] File paths are validated (no path traversal)
- [ ] API endpoints have proper authentication/authorization

## Testing
- [ ] New code has corresponding tests
- [ ] Edge cases are tested
- [ ] Tests are deterministic (no flaky tests)
- [ ] Test names describe the scenario being tested

## Performance
- [ ] No N+1 query patterns
- [ ] Large data sets are paginated
- [ ] Expensive operations are cached where appropriate
- [ ] No unnecessary memory allocations in hot paths

## Documentation
- [ ] Public APIs have clear documentation
- [ ] Breaking changes are documented
- [ ] README is updated if user-facing behavior changed
