# Step 1 — AI-Assisted Data Discovery

**Phase:** DISCOVER  
**Time:** ~5 minutes

> **The pitch:** CoCo knows your Snowflake catalog. Instead of spelunking through Snowsight for 20 minutes, you describe what you need in plain English and CoCo surfaces the right tables, profiles the data, and explains the relationships — in seconds.

---

## What You'll Showcase

- CoCo's built-in catalog awareness (no skill needed — it knows your environment)
- Natural language schema exploration
- Instant data profiling (row counts, nulls, distributions)
- Relationship inference across tables

---

## Demo Prompts

### 1.1 — Orient to the schema

```
I'm working on a Portfolio Risk Analytics pipeline for an asset management firm.
I'm starting fresh in this schema. What tables do I have available, and what does each one appear to contain?
For each table, give me:
- A one-line business description
- The most important columns
- An estimate of how many rows it has
- Which tables look most relevant to building a portfolio risk Silver layer
```

| What to look for |
|---|
| CoCo queries INFORMATION_SCHEMA automatically — no manual SQL needed |
| A clear, business-friendly summary of each table without you opening a single object |
| CoCo calling out PORTFOLIO_HOLDINGS and ASSET_PRICES as the core tables |

---

### 1.2 — Profile the most important table

```
Profile the PORTFOLIO_HOLDINGS table. I want to understand:
1. Row count and date range of as_of_date
2. How many distinct portfolio_id values and what they are
3. Breakdown of market_value_usd — min, max, average, and any obvious outliers
4. Percentage of NULL values in each column
5. Whether asset_class and sector have any unexpected values
```

| What to look for |
|---|
| CoCo runs targeted profiling SQL and surfaces the results in a readable summary |
| Any data quality issues flagged immediately — nulls, outliers, unexpected categories |
| The demo shows the step that normally takes an engineer 30 minutes of ad-hoc queries |

---

### 1.3 — Infer relationships

```
Based on the tables in this schema, map out the relationships between them.
Which columns link PORTFOLIO_HOLDINGS to ASSET_PRICES, BENCHMARK_WEIGHTS, and TRADE_HISTORY?
Are there any potential referential integrity issues I should know about before building a pipeline?
For example: tickers in PORTFOLIO_HOLDINGS that have no price data in ASSET_PRICES.
```

| What to look for |
|---|
| CoCo infers FK relationships from naming patterns without being told |
| A concrete query checking for orphaned tickers — the kind of check that catches production bugs early |
| Relationship map presented as a clear summary, not raw SQL |

---

### 1.4 — Ask a natural language business question (live audience moment)

```
Which portfolio has the highest concentration in the Technology sector,
and how does that compare to the S&P 500 benchmark weighting for the same sector?
```

| What to look for |
|---|
| CoCo writes the multi-table JOIN query, runs it, and explains the result in plain English |
| The result answers a real business question — sector overweight vs benchmark |
| **This is the "wow" moment**: the audience sees a natural language question become a live answer |

---

## Success Criteria

- [ ] CoCo identifies all 4 tables without being told their names
- [ ] Data profile surfaces at least one data quality observation
- [ ] Relationship query finds tickers without price coverage (expected: a few tickers)
- [ ] Business question returns a clear portfolio + sector comparison

---

*Proceed to → [Step 2 — Design](./Step2-Design.md)*
