# AI-Assisted Engineering: CoCo Demo Guide
**London Techfest — September 2026**

> Walk-through of the full data engineering lifecycle for a Portfolio Risk Analytics use case, showcasing Cortex Code (CoCo) at every phase.

---

## The Story

The risk analytics team at a financial services firm has raw portfolio and market data in Snowflake. Today they ship a Silver-grade Portfolio Risk pipeline — entirely through natural language with CoCo.

| Step | Phase | What You'll Demonstrate | Key CoCo Capability |
|---|---|---|---|
| [0 — Setup](./Step0-Setup.md) | PRE-DEMO | Create tables, seed data, validate environment | Run before audience arrives — not part of the live demo |
| [1 — Discover](./Step1-Discover.md) | DISCOVER | Explore an unknown schema, profile data, infer relationships | Catalog awareness, natural language exploration |
| [2 — Design](./Step2-Design.md) | DESIGN | Generate realistic synthetic portfolio data | `$snowpark` skill, Snowpark Python generation |
| [3 — Build](./Step3-Build.md) | BUILD | Build a Silver Dynamic Table pipeline, explain complex SQL | `$dynamic-tables` skill, Plan Mode |
| [4 — Test](./Step4-Test.md) | TEST | Generate a validation suite, catch data quality issues | `$error-tables-ops` skill, AI-generated test SQL |
| [5 — Monitor](./Step5-Monitor.md) | MONITOR | Diagnose a pipeline failure, trace root cause through lineage | `$dynamic-tables Troubleshoot`, Pipeline Diagnostics |
| [6 — Optimize](./Step6-Optimize.md) | OPTIMIZE | Rewrite slow queries, right-size warehouses | `$dynamic-tables Optimize`, Apply Recommendations |

**Total demo time: ~35–40 minutes** (Steps 1–6; Steps 3 and 5 have the richest moments)

---

## Setup (Before the Demo)

See **[Step 0 — Setup](./Step0-Setup.md)** for the full pre-demo checklist:
- Install CoCo CLI
- Create your personal schema
- Edit `AGENTS.md` with your database/schema/warehouse
- Run the table creation and data seeding prompt
- Validate data integrity

> Run Step 0 the day before or 15 minutes before the audience arrives. The live demo starts at Step 1.

---

## Quick Reference

| Action | Command |
|---|---|
| List available skills | `/skill list` |
| Enable Plan Mode | `Ctrl+P` or `/plan` |
| Reference a local file | `@filename.sql` |
| Run a shell command | `!<command>` |
| Undo last action | `/rewind` |
| Compact session context | `/compact` |

---

## Bundled Skills Used in This Demo

| Skill | Steps Used | What It Does |
|---|---|---|
| `$dynamic-tables Create` | Step 3 | Generates Silver Dynamic Table with operating runbook |
| `$dynamic-tables Monitor` | Step 5 | Explains refresh state, lag, and staleness patterns |
| `$dynamic-tables Troubleshoot` | Step 5 | Diagnoses pipeline failures and proposes fixes |
| `$dynamic-tables Optimize` | Step 6 | Recommends clustering keys, TARGET_LAG, warehouse sizing |
| `$dynamic-tables Apply Recommendations` | Step 6 | Applies emitted Snowflake recommendations to the DT |
| `$error-tables-ops Assess` | Step 4 | Identifies which tables should have error logging |
| `$error-tables-ops Discover` | Step 4 | Finds DML errors already captured in error tables |
| `$snowpark Development` | Step 2 | Generates production Snowpark Python data pipelines |
| `$snowflake-tasks Monitor` | Step 5 | Checks task graph health and failure history |
