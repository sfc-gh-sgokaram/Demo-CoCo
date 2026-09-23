# Step 0 — Environment Setup and Data Seeding

**When to run:** Before the demo (day before, or 15 minutes before the audience arrives)  
**Time:** ~10 minutes

> This step creates the 4 source tables and seeds them with realistic financial data. The demo narrative starts at Step 1 (Discover), where CoCo "finds" this data — so the tables must exist before the audience walks in.

---

## Prerequisites

### 1. Install CoCo CLI

```bash
# macOS / Linux
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh
cortex --version
```

```powershell
# Windows (PowerShell)
irm https://ai.snowflake.com/static/cc-scripts/install.ps1 | iex
cortex --version
```

### 2. Create your personal schema

In Snowsight, run:

```sql
CREATE SCHEMA IF NOT EXISTS <DATABASE>.<YOUR_NAME>_COCO_DEMO;
```

### 3. Edit `AGENTS.md`

Open `AGENTS.md` in this directory and replace the three placeholders:

```
USE DATABASE <DATABASE>;
USE SCHEMA <YOUR_NAME>_COCO_DEMO;
USE WAREHOUSE <WAREHOUSE>;
```

### 4. Launch CoCo from this directory

```bash
cd Demo-CoCo/
cortex -c <your_connection_name>
```

### 5. Verify context

```
What database, schema, and warehouse am I targeting?
```

---

## Setup Prompt — Create Tables and Seed Data

Paste into the CoCo prompt:

```
I'm building a Finance Asset Management demo in Snowflake.
Use the context from AGENTS.md for database/schema references.

Create these 4 tables (DROP IF EXISTS so the script is re-runnable):
- PORTFOLIO_HOLDINGS (portfolio_id, asset_id, ticker, asset_class, sector, quantity, market_value_usd, as_of_date)
- ASSET_PRICES (asset_id, ticker, price_date, close_price, volume)
- BENCHMARK_WEIGHTS (benchmark_id, benchmark_name, ticker, weight_pct, as_of_date)
- TRADE_HISTORY (trade_id, portfolio_id, ticker, trade_type, quantity, trade_price, trade_date)

Then insert ~100 rows of realistic data into each table:
- Use real tickers: AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA, JPM, BAC, GS, V, MA, JNJ, UNH, PFE, XOM, CVX, PG, KO, WMT
- 3 portfolio IDs: BLK_CORE_EQ, BLK_GROWTH, BLK_VALUE
- ASSET_PRICES: 30 days ending today, ~2% daily variation
- BENCHMARK_WEIGHTS: weights sum to exactly 100 per as_of_date
- TRADE_HISTORY: mix of BUY/SELL over last 90 days

Save to setup.sql and execute it.
Then verify with:
SELECT 'PORTFOLIO_HOLDINGS' AS tbl, COUNT(*) AS row_count FROM PORTFOLIO_HOLDINGS UNION ALL
SELECT 'ASSET_PRICES',              COUNT(*)                 FROM ASSET_PRICES      UNION ALL
SELECT 'BENCHMARK_WEIGHTS',         COUNT(*)                 FROM BENCHMARK_WEIGHTS UNION ALL
SELECT 'TRADE_HISTORY',             COUNT(*)                 FROM TRADE_HISTORY;
```

---

## Validation Prompt

Run this immediately after to confirm data integrity before the demo:

```
Write and run a query that validates:
1. BENCHMARK_WEIGHTS sums to 100 per as_of_date
2. Any tickers in PORTFOLIO_HOLDINGS with no price data in ASSET_PRICES
3. Any TRADE_HISTORY records where trade_price is 0 or NULL

Flag any issues clearly so I can fix them before the demo starts.
```

---

## Success Criteria

- [ ] All 4 tables created and populated
- [ ] Verification query shows row counts > 0 for all tables
- [ ] BENCHMARK_WEIGHTS sums to 100 for every as_of_date
- [ ] No NULL or zero trade prices
- [ ] At least 2–3 tickers in PORTFOLIO_HOLDINGS with no price data (expected — this becomes the "discovery moment" in Step 1)

> **Note on the missing price gap:** Leave any tickers without full ASSET_PRICES coverage — CoCo will "discover" this in Step 1.3 and it makes for a stronger demo moment. Do not fix it.

---

## Pre-Demo Dry Run — Required for Steps 6.2–6.4 to work live

**Run this the day before, not 15 minutes before.** Several Step 6 prompts depend on Snowflake system data that is not instant:

| Dependency | Latency | Used by |
|---|---|---|
| `ACCOUNT_USAGE.QUERY_HISTORY` / `ACCESS_HISTORY` / `STORAGE_USAGE` | 45 min – 3 hours | Steps 6.3, 6.4 |
| Dynamic Table `RECOMMENDATIONS` (execution-based insights like `WAREHOUSE_TOO_SMALL`, `HIGH_BASE_TABLE_CHANGES`) | Accumulates over multiple real refreshes, not instant | Step 6.2 |

If you build `SILVER_PORTFOLIO_RISK` for the first time live in front of the audience, Steps 6.2–6.4 have a real chance of returning "nothing found" — not because the skill is broken, but because the underlying account data hasn't caught up yet.

**Fix:** Run through Steps 1–6 once, end-to-end, using the exact prompts, at least a few hours before (ideally the day before) the live session. Step 3's prompt is written to use `CREATE OR ALTER DYNAMIC TABLE` (see Step 3.2) specifically so that re-running it live does **not** wipe the refresh history and recommendations you warmed up in this dry run — the live audience sees the same "build" moment, but Step 6 now has real data to show.

- [ ] Dry run of Steps 1–6 completed at least a few hours before the live session
- [ ] `SILVER_PORTFOLIO_RISK` has accumulated at least 3–4 refreshes (initial + a couple of manual `ALTER DYNAMIC TABLE ... REFRESH` calls) before the live show
- [ ] Confirmed `$dynamic-tables Apply Recommendations` returns at least one recommendation during the dry run (if not, don't rely on it live — see Step 6.2 fallback)

---

*When setup is complete → Start the demo at [Step 1 — Discover](./Step1-Discover.md)*
