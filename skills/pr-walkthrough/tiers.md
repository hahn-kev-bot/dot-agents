# Priority tiers

Read top → bottom. Assign by *why* the file changed, not where it lives. Spans
two tiers → highest tier, note the secondary aspect. Tie → higher tier.

| Tier | Label | What belongs here |
| ---- | ----- | ----------------- |
| 1 | **Core change** | Implements the fundamental behavior — why the PR exists |
| 2 | **Contracts & data** | Types, schemas, interfaces, models, API shapes |
| 3 | **Integration & wiring** | Routes, handlers, UI entry points, DI, feature flags |
| 4 | **Supporting behavior** | Errors, logging, migrations, secondary features |
| 5 | **Tests** | Tests, fixtures, snapshots |
| 6 | **Config & tooling** | CI, build, env templates, scripts, lockfile-only |
| 7 | **Incidental** | Formatting, import reorder, logic-free renames, generated boilerplate |

## Examples

- `services/billing/refund.ts` (new refund logic) → Core change
- `types/billing.ts` (RefundRequest) → Contracts & data
- `api/routes/billing.ts` (POST /refunds) → Integration & wiring
- `__tests__/refund.test.ts` → Tests
- `.github/workflows/ci.yml` → Config & tooling
- `package-lock.json` only → Incidental

## Explanation voice

State what the code does now. Example: "`refund.ts` adds `processRefund()`,
which loads the order, validates eligibility, calls the payment provider, and
records the result."