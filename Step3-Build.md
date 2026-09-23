# Step 3 — AI-Assisted Code Generation and Pipeline Build

**Phase:** BUILD  
**Time:** ~8 minutes (richest step — allocate time here)

> **The pitch:** Building a Silver-grade pipeline normally means hours of SQL authoring, schema wrangling, and documentation. CoCo uses Plan Mode to think through the task first, then the `$dynamic-tables` skill to produce production-ready SQL, an operating runbook, and explained code — in minutes.

---

## What You'll Showcase

- **Plan Mode** (`Ctrl+P`) — CoCo plans before it acts on complex multi-step tasks
- **`$dynamic-tables Create`** skill — generates Silver Dynamic Table with explainable SQL
- Natural language → complex SQL (window functions, CTEs, JOINs)
- CoCo explaining legacy/complex SQL code

---

## Demo Prompts

### 3.0 — List and inspect the skill

```
/skill list
```

```
What does the $dynamic-tables skill do?
Summarize when to use it, what inputs it expects, and what it returns.
```

| What to look for |
|---|
| Audience sees skill discovery in action — CoCo can explain its own capabilities |
| Sets up the "bundled vs custom skill" narrative for the audience |

---

### 3.1 — Enable Plan Mode before the complex build task

> **Tip for presenter:** Before typing the prompt, press `Ctrl+P` and explain to the audience what Plan Mode is.

**What to say:** *"For a task this complex — joining 4 tables, applying business logic, creating a production object — I don't want CoCo to just start writing SQL. I want it to plan the approach first, show me the steps, and wait for my approval. That's Plan Mode."*

```
Ctrl+P   ← press these keys now to enter Plan Mode
```

---

### 3.2 — Build the Silver Portfolio Risk Dynamic Table

```
Use the $dynamic-tables Create skill.

Build a Silver-grade Dynamic Table called SILVER_PORTFOLIO_RISK in my current schema.

Business requirements:
- Combine PORTFOLIO_HOLDINGS, ASSET_PRICES, BENCHMARK_WEIGHTS, and TRADE_HISTORY
- Calculate for each holding:
  * current_price: latest close_price from ASSET_PRICES
  * market_value_usd: quantity × current_price
  * weight_pct: holding's share of total portfolio market value
  * benchmark_weight_pct: corresponding weight from the S&P 500 benchmark
  * active_weight_pct: weight_pct minus benchmark_weight_pct
  * position_label: OVERWEIGHT if active_weight > 2, UNDERWEIGHT if < -2, else NEUTRAL
  * 30d_return_pct: 30-day price return from ASSET_PRICES
  * recent_trade_type: most recent trade direction (BUY/SELL) from TRADE_HISTORY

TARGET_LAG: 1 hour (prices update daily but we want headroom)

Use CREATE OR ALTER DYNAMIC TABLE, not CREATE OR REPLACE — I may re-run this
during rehearsal and don't want to wipe refresh history or reset recommendations.

Return:
1. The complete Dynamic Table SQL with readable CTEs
2. The reasoning behind the TARGET_LAG choice
3. A short operating runbook (key monitoring queries + failure patterns to watch)
```

| What to look for |
|---|
| Plan Mode shows a structured multi-step plan BEFORE any SQL is written |
| After approving, `$dynamic-tables Create` produces readable CTEs — not a monolithic query |
| The operating runbook is immediately usable, not generic boilerplate |
| CoCo makes design choices explicit (e.g. why LAG_PERIOD = 1 hour) |
| Generated DDL uses `CREATE OR ALTER DYNAMIC TABLE`, not `CREATE OR REPLACE` |

> Exit Plan Mode when prompted to approve execution.

> **Presenter tip (speed/reliability):** If you did the pre-demo dry run (see [Step 0](./Step0-Setup.md)), this table already exists with warmed-up refresh history. Because the prompt asks for `CREATE OR ALTER`, running it live again is a fast no-op if the definition matches — you still get the full plan + SQL walkthrough for the audience, but Step 6's recommendations and cost data will actually have something to show.

---



### 3.4 — Explain a complex query

```
Explain @complex_query.sql step by step.
For each CTE, describe:
1. What business concept it computes
2. Why it uses the window functions it does
3. How it feeds into the final SELECT

Also explain why NULLIF is used and what would break without it.
```

> **Note:** Use the `complex_query.sql` from the existing COCO-HOL, or generate one during Step 3.2 and reference it here.

| What to look for |
|---|
| **Audience moment:** CoCo explains a query an engineer would need 20 minutes to reverse-engineer |
| Plain-English CTE walkthrough, not just SQL syntax comments |
| The "code explanation" capability resonates strongly with anyone who has inherited legacy pipelines |

---

### 3.5 — Proof query

```
Give me one concise proof query for SILVER_PORTFOLIO_RISK that:
- Shows the count of OVERWEIGHT, UNDERWEIGHT, and NEUTRAL holdings per portfolio
- Is easy to rerun after any future schema change
Save it to silver_proof.sql.
```

---

## Success Criteria

- [ ] Plan Mode displayed a structured plan before executing
- [ ] `SILVER_PORTFOLIO_RISK` Dynamic Table created successfully
- [ ] Operating runbook generated (at least 2 monitoring queries)
- [ ] Complex query explanation delivered in plain English
- [ ] Proof query returns results showing all 3 position labels

---

*Proceed to → [Step 4 — Test](./Step4-Test.md)*
