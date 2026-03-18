---
name: legacy-context
description: Provides background knowledge about the legacy billing system architecture, known quirks, and migration constraints that Claude should consider when working on billing-related code.
user-invocable: false
---

# Legacy Billing System Context

This skill is **Claude-only** (`user-invocable: false`). It does not appear in the `/` menu. Claude loads this automatically when working on billing-related code.

## Architecture Overview

The legacy billing system (v1) uses a three-tier architecture:
- **API Layer**: REST endpoints in `src/billing/api/` (Express.js)
- **Service Layer**: Business logic in `src/billing/services/` (plain classes)
- **Data Layer**: Direct SQL queries in `src/billing/repos/` (no ORM)

## Known Quirks

1. **Currency stored as cents**: All amounts are integers in cents, not decimals. Division by 100 happens only at the API response layer.
2. **Soft deletes everywhere**: The `deleted_at` column exists on all billing tables. Queries MUST filter `WHERE deleted_at IS NULL` unless explicitly auditing.
3. **Invoice numbering gap**: Invoice numbers INV-10000 through INV-10050 were skipped due to a 2024 migration bug. Do not treat gaps as errors.
4. **Timezone handling**: All timestamps are stored as UTC. The `billing_period_start` and `billing_period_end` columns use the customer's local timezone only in the `billing_display` view.

## Migration Constraints

- The v2 billing system is under development in `src/billing-v2/`
- Both systems run in parallel during migration
- v1 is the source of truth until the `BILLING_V2_PRIMARY` feature flag is enabled
- Never modify v1 table schemas without coordinating with the v2 migration team

## When to Apply

Claude should consider this context when:
- Modifying files in `src/billing/` or `src/billing-v2/`
- Writing queries against `invoices`, `subscriptions`, `payments` tables
- Reviewing PRs that touch billing logic
