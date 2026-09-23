# Step 6 — AI-Assisted Optimization and Cost Governance

**Phase:** OPTIMIZE  
**Time:** ~5 minutes

> **The pitch:** The pipeline is live and healthy. Now CoCo makes it faster and cheaper — rewriting inefficient SQL, recommending the right warehouse size, flagging cost overruns, and applying Snowflake's own emitted recommendations. All without a performance engineer on the team.

---

## What You'll Showcase

- **`$dynamic-tables Optimize`** skill — recommends clustering, TARGET_LAG, and warehouse sizing
- **`$dynamic-tables Apply Recommendations`** skill — applies Snowflake-emitted DT recommendations
- CoCo reading query profiles and rewriting slow SQL
- Cost attribution: finding the most expensive queries and flagging them

---

## Demo Prompts

### 6.1 — Get optimization recommendations for the pipeline

```
$dynamic-tables Optimize

Analyze SILVER_PORTFOLIO_RISK and give me optimization recommendations:
1. Is the current TARGET_LAG appropriate given the source data refresh cadence?
2. Should I add a clustering key? If so, which column(s) and why?
3. Is the warehouse size appropriate for the data volume?
4. Are there any query patterns in the DT SQL that are known to prevent incremental refresh?
```

| What to look for |
|---|
| Recommendations are specific to this table, not generic DT advice |
| Clustering key recommendation explains the query patterns that justify it |
| If full-refresh-instead-of-incremental is happening, the skill flags it and explains why |

---

### 6.2 — Apply Snowflake's emitted recommendations

```
$dynamic-tables Apply Recommendations

Check if Snowflake has emitted any recommendations for SILVER_PORTFOLIO_RISK.
Show me what they are and apply the ones that are safe to apply automatically.
```

| What to look for |
|---|
| The skill reads the `RECOMMENDATIONS` column from DT metadata — no manual SQL |
| Each recommendation shown with its rationale before being applied |
| `AUTO_RESOLVED_TO_FULL_REFRESH` and `WAREHOUSE_TOO_SMALL` are common ones to catch here |

> **Presenter fallback (reliability):** Structural insights (SQL-pattern based, e.g. `QUALIFY_RANK_NOT_TOP_LEVEL`) can appear right after the first refresh. Execution-based insights (`WAREHOUSE_TOO_SMALL`, `HIGH_BASE_TABLE_CHANGES`) need several real refreshes to accumulate and won't exist if this table was only just built live. This is exactly why the [Step 0 pre-demo dry run](./Step0-Setup.md) matters — if you skipped it and the recommendations list is empty, don't stall: tell the audience "no recommendations yet — this table is brand new, they accumulate after a few refresh cycles" and move to 6.3.

---

### 6.3 — Identify the most expensive query in the pipeline

```
The DBA team says our portfolio analytics warehouse is spending too many credits.
Look at the query history for SILVER_PORTFOLIO_RISK refreshes.
Use INFORMATION_SCHEMA (e.g. QUERY_HISTORY() / DYNAMIC_TABLE_REFRESH_HISTORY()) for
this, not ACCOUNT_USAGE — ACCOUNT_USAGE views lag 45 min to 3 hours and this table
was created recently.
Tell me:
1. How many credits per refresh is the DT consuming on average?
2. Which part of the SQL (which CTE or JOIN) is the most expensive?
3. Rewrite the most expensive section to be more efficient.
4. Estimate the credit saving if we apply the rewrite.
```

| What to look for |
|---|
| CoCo queries near-real-time INFORMATION_SCHEMA data — not ACCOUNT_USAGE, which may show nothing yet for a table created minutes ago |
| The rewrite targets the specific bottleneck (usually the cross-join with BENCHMARK_WEIGHTS) |
| Credit saving estimate given with the assumptions stated explicitly |

---

### 6.4 — Cost attribution and dead code detection

```
Scan the TEMP.PUBLIC schema (not my personal demo schema — it was built today
and won't have 30-day-old dead objects) and tell me:
1. Are there any tables or views that haven't been queried in the last 30 days?
2. Which objects are consuming the most storage?
3. Propose a safe cleanup plan — what can be archived or dropped, and what evidence supports each recommendation?
```

| What to look for |
|---|
| CoCo queries ACCESS_HISTORY and STORAGE_USAGE — not just guessing from table size |
| "Safe cleanup" means backed by evidence: last query timestamp, downstream lineage check |
| **Audience moment:** dead code detection is something engineers almost never do proactively |

> **Presenter tip (reliability):** Your own demo schema was created today, so a scan scoped to it will correctly find *nothing* — a flat, anticlimactic result live. Point CoCo at a schema with real history (e.g. `TEMP.PUBLIC`, which has genuinely stale objects) so the "audience moment" actually lands. Also remember ACCESS_HISTORY/STORAGE_USAGE lag up to ~3 hours, so this reflects account activity as of a few hours ago, not this exact minute.

---

### 6.5 — Final summary (closing moment)

```
Summarise what we built and optimised in this session.
For each of the 6 steps — Discover, Design, Build, Test, Monitor, Optimize —
give one sentence on what CoCo did and what the traditional effort would have been.
```

| What to look for |
|---|
| A clean closing narrative that reinforces the "speed of thought" message |
| Each step contrasted: "traditionally X hours, with CoCo X minutes" |
| Ends the demo with a clear takeaway the audience can repeat |

---

## Success Criteria

- [ ] `$dynamic-tables Optimize` returns at least 2 actionable recommendations
- [ ] `$dynamic-tables Apply Recommendations` reads and applies at least one recommendation
- [ ] Slow query identified and rewrite proposed with credit estimate
- [ ] Dead code scan returns at least one candidate for cleanup
- [ ] Session summary generated as a clean narrative

---

## End of Demo

**Total story delivered:**  
One financial services team. One Portfolio Risk pipeline. Built, tested, monitored, and optimised — entirely through natural language with Cortex Code.

The same workflow that would take a team of 3 engineers 2 sprints: done in 35 minutes.

---

*← Back to [README](./README.md)*
