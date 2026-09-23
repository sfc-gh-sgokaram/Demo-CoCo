# Step 4 — AI-Assisted Validation

**Phase:** TEST  
**Time:** ~5 minutes

> **The pitch:** The pipeline is built. Now CoCo generates a validation suite that catches the issues you'd never think to check manually — null leakage, weight drift, referential integrity failures, and bad aggregates. It also uses the `$error-tables-ops` skill to assess which tables need DML error logging.

---

## What You'll Showcase

- CoCo generating targeted SQL validation checks from business rules
- **`$error-tables-ops Assess`** skill — identifies which tables should have error logging enabled
- Edge case generation (nulls, boundary values, referential integrity)
- Natural language business rules → executable SQL

---

## Demo Prompts

### 4.1 — Generate a validation suite

```
Write a validation suite for SILVER_PORTFOLIO_RISK.

I want checks that would catch silent data quality failures — not just "does the table have rows" but business-logic checks. Include:

1. Weight completeness: weight_pct should sum to ~100% per portfolio_id (allow ±0.1% for rounding)
2. Active weight sanity: active_weight_pct should never exceed ±50% for any single holding
3. Price currency: current_price should never be NULL or zero
4. Return bounds: 30d_return_pct should be between -80% and +300% (flag outliers, don't fail)
5. Referential integrity: every ticker in SILVER_PORTFOLIO_RISK should have at least 20 trading days of price data in ASSET_PRICES
6. Duplicate check: each (portfolio_id, ticker) combination should appear exactly once

Return each check as a separate named SQL query I can run independently.
Save the full suite to validation_suite.sql.
```

| What to look for |
|---|
| CoCo generates 6 distinct, named checks — not one monolithic validation script |
| The referential integrity check and duplicate check are the kind of tests engineers rarely write upfront |
| Each check is structured so a CI pipeline can run them independently |

---

### 4.2 — Run the validation suite

```
Run validation_suite.sql.
For each check, report: PASS, FAIL, or WARNING with a count of affected rows.
If any check fails, explain what it means for the downstream risk analytics use case.
```

| What to look for |
|---|
| CoCo runs each check and formats the results as a clear pass/fail table |
| Any failures are explained in business terms, not just "query returned rows" |
| **Audience moment:** watch CoCo catch an issue that would have silently corrupted a risk report |

---

### 4.3 — Use the $error-tables-ops skill to assess error logging coverage

```
$error-tables-ops Assess

Assess the tables in my current schema and tell me:
1. Which tables should have error logging (error tables) enabled
2. What DML error patterns are most likely for each table
3. The SQL to enable error logging on the highest-priority table
```

| What to look for |
|---|
| The skill provides structured assessment, not generic advice |
| Prioritisation by risk (SILVER_PORTFOLIO_RISK and TRADE_HISTORY should rank highest) |
| Audience sees how a bundled skill replaces 30 minutes of documentation reading |

---

### 4.4 — Translate a business rule into a test (live audience moment)

```
The risk team just sent me this rule: "No single holding should represent more than 15%
of any portfolio's total market value — this is a concentration risk limit."

Write a SQL check that enforces this rule and flags any current violations.
Then write the version I'd add to a dbt test or a scheduled Snowflake task.
```

| What to look for |
|---|
| **Audience moment:** a compliance rule stated in plain English becomes executable SQL instantly |
| Both a one-off check AND a re-runnable scheduled test version are generated |
| Demonstrates the gap between what engineers write vs what CoCo writes |

---

## Success Criteria

- [ ] `validation_suite.sql` created with 6 named checks
- [ ] All checks run and return PASS/FAIL/WARNING with row counts
- [ ] `$error-tables-ops Assess` recommends at least 2 tables and provides the enabling SQL
- [ ] Concentration risk rule check runs and returns results

---

*Proceed to → [Step 5 — Monitor](./Step5-Monitor.md)*
