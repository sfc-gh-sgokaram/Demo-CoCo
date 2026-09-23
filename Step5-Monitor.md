# Step 5 — AI-Assisted Operational Triage

**Phase:** MONITOR  
**Time:** ~7 minutes

> **The pitch:** The risk pipeline has stopped refreshing. CoCo distinguishes a suspended scheduler from a failed refresh, checks freshness and downstream impact, and proposes a targeted recovery without changing healthy source data.

---

## What You'll Showcase

- **`$dynamic-tables Monitor`** skill — explains current refresh state, lag, and staleness
- **`$dynamic-tables Troubleshoot`** skill — diagnoses failures and proposes targeted fixes
- **`$dynamic-tables Pipeline Diagnostics`** — visualises the full pipeline timeline
- **`$snowflake-tasks Monitor`** skill — checks task graph health if tasks are involved
- CoCo tracing root cause through lineage in plain English

---

## Setup (Presenter): Simulate a Suspended Pipeline

Use a manual suspension in the demo schema. This is a scheduling incident, not an SQL execution failure. It preserves the DT definition, data, and refresh history. Run this in Snowsight before 5.1:

```sql
USE DATABASE TEMP;
USE SCHEMA SGOKARAM_COCO_DEMO;
USE WAREHOUSE SE_WH;

ALTER DYNAMIC TABLE SILVER_PORTFOLIO_RISK SUSPEND;
SHOW DYNAMIC TABLES LIKE 'SILVER_PORTFOLIO_RISK'
    IN SCHEMA TEMP.SGOKARAM_COCO_DEMO;
```

**Setup checkpoint:** `scheduling_state` must be `SUSPENDED`. The last completed refresh can still be `SUCCEEDED`, and an empty error history is expected. Suspension does not immediately make the data stale; only claim a target-lag breach if the measured data age exceeds the configured 1-hour target. Do not run `REFRESH` until recovery in 5.3.



## Demo Prompts

### 5.1 — Check pipeline health

```
$dynamic-tables Monitor

Check the health of SILVER_PORTFOLIO_RISK in my current schema.
Tell me:
1. Scheduling state (ACTIVE or SUSPENDED), separately from the last refresh outcome
2. Current data age from the DT data timestamp, compared with its target lag
3. When did the last successful refresh complete?
4. Are there any errors in the refresh history? Report none if there are none.
5. Refresh mode and its reason; do not treat FULL as a failure
Use SHOW DYNAMIC TABLES and INFORMATION_SCHEMA functions for live results.
Do not resume or refresh the table during this read-only check.
```

| What to look for |
|---|
| The skill queries INFORMATION_SCHEMA and DT system views — no manual query writing |
| Scheduling state is SUSPENDED even if the last refresh outcome is SUCCEEDED |
| Data age is compared with the 1-hour freshness target, not an assumed hourly schedule |
| No refresh error is invented: manual suspension need not produce a FAILED history row |

---

### 5.2 - Diagnose why scheduling stopped

```
$dynamic-tables Troubleshoot

SILVER_PORTFOLIO_RISK is not automatically refreshing.
Investigate and tell me:
1. Is this suspension, a refresh execution error, or a target-lag breach?
2. What evidence explains why scheduling stopped? Check suspension metadata and
   recent query history where available; distinguish manual from automatic suspension.
3. Is there evidence of an upstream failure? Do not assume bad source data.
4. What is the exact fix I need to apply?
5. Which downstream Dynamic Tables depend on it, if any, and what is their state?
Keep this read-only and do not apply the fix yet.
```

| What to look for |
|---|
| The skill separates scheduler state, refresh outcome, and data freshness |
| Root cause is manual suspension, supported by available metadata/query history; any evidence gaps are stated |
| Downstream impact is assessed without inventing consumers or upstream errors |
| **Audience moment:** targeted operational recovery instead of unnecessary source-data edits |

---

### 5.3 — Apply the fix

```
Resume SILVER_PORTFOLIO_RISK, then request an immediate manual refresh with
ALTER DYNAMIC TABLE ... REFRESH instead of waiting for the scheduler.
Do not edit ASSET_PRICES or recreate the DT for this suspension incident.
Verify scheduling_state is ACTIVE and the requested refresh finishes as SUCCEEDED.
Identify that refresh by its query ID or request time, not an older successful run.
Show its state, refresh action, completion time, and data timestamp.
Run silver_proof.sql from Step 3.5 after the refresh completes. If it is absent,
run the equivalent position-label counts per portfolio and as_of_date.
```

| What to look for |
|---|
| CoCo resumes and refreshes the DT without changing source data or replacing the definition |
| The newly requested refresh succeeds; FULL or NO_DATA can both be valid actions |
| The proof query runs after completion, not merely after the refresh request |

> **Presenter tip (speed):** `RESUME` enables scheduling; `REFRESH` requests work immediately. Completion still depends on warehouse availability and query runtime. Wait for that refresh to finish before claiming recovery.

Read-only recovery evidence (the latest row must correspond to the refresh just requested):

```sql
USE DATABASE TEMP;
USE SCHEMA SGOKARAM_COCO_DEMO;
USE WAREHOUSE SE_WH;

SHOW DYNAMIC TABLES LIKE 'SILVER_PORTFOLIO_RISK'
    IN SCHEMA TEMP.SGOKARAM_COCO_DEMO;

SELECT query_id, state, state_message, refresh_action, refresh_trigger,
       refresh_start_time, refresh_end_time, data_timestamp
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
    NAME => 'TEMP.SGOKARAM_COCO_DEMO.SILVER_PORTFOLIO_RISK',
    RESULT_LIMIT => 20
))
ORDER BY refresh_start_time DESC
LIMIT 5;
```

---

### 5.4 — Set up an alert so this never goes undetected again

```
$dynamic-tables Alerting

Create a Snowflake alert that fires when SILVER_PORTFOLIO_RISK has not refreshed
successfully within 90 minutes of its expected schedule.

The alert should:
- Check every 30 minutes
- Send a notification to a webhook (I'll provide the URL separately)
- Include the table name, last refresh time, and current lag in the message body
```

| What to look for |
|---|
| The skill generates a complete `CREATE ALERT` statement — not just advice |
| Alert condition is precise: checks actual refresh timestamp, not just task state |
| Demonstrates proactive monitoring coming out of a reactive triage — the full loop |

---

### 5.5 — Check task graph health (if using Tasks)

```
$snowflake-tasks Monitor

Show me the health of any Snowflake Tasks in my current schema.
For any that have failed recently, explain what failed and why.
```

---

## Success Criteria

- [ ] `$dynamic-tables Monitor` reports SUSPENDED separately from the last refresh outcome
- [ ] Actual data age is measured; an immediate target-lag breach or refresh error is not assumed
- [ ] `$dynamic-tables Troubleshoot` identifies manual suspension with supporting evidence
- [ ] DT resumed to ACTIVE, newly requested refresh SUCCEEDED, proof query runs clean
- [ ] Alert `CREATE` statement generated targeting the correct condition

---

*Proceed to → [Step 6 — Optimize](./Step6-Optimize.md)*
