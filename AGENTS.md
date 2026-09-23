# Snowflake Context

Every SQL execution must be preceded by these USE statements:

```sql
USE DATABASE TEMP;
USE SCHEMA SGOKARAM_COCO_DEMO;
USE WAREHOUSE SE_WH;
```


## Rules

1. Always prepend the USE statements above before executing any SQL.
2. Never assume session context persists between tool calls.
3. Output tables belong in the current schema unless explicitly stated otherwise.
4. For Streamlit apps, use `get_active_session()` — never hardcode database, schema, or warehouse.
