-- ============================================================================
-- validation_suite.sql
-- Business-logic validation suite for SILVER_PORTFOLIO_RISK
-- Schema: TEMP.SGOKARAM_COCO_DEMO
--
-- Each check is an independent, runnable query. Checks 1-3 and 5-6 are FAIL
-- checks (any row returned = violation). Check 4 is a FLAG check (outliers
-- are surfaced for review, not treated as hard failures).
--
-- Convention: every query returns zero rows when the data passes.
-- (Check 4 intentionally returns rows when outliers exist — inspect, don't fail.)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CHECK 1: weight_completeness
-- weight_pct should sum to ~100% per portfolio_id (tolerance ±0.1% for rounding)
-- Returns one row per portfolio that is out of tolerance.
-- ----------------------------------------------------------------------------
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
SELECT
    PORTFOLIO_ID,
    ROUND(SUM(WEIGHT_PCT), 4)                    AS total_weight_pct,
    ROUND(SUM(WEIGHT_PCT) - 100, 4)              AS deviation_pct,
    COUNT(*)                                      AS holdings
FROM SILVER_PORTFOLIO_RISK
GROUP BY PORTFOLIO_ID
HAVING ABS(SUM(WEIGHT_PCT) - 100) > 0.1
ORDER BY ABS(SUM(WEIGHT_PCT) - 100) DESC;

-- ----------------------------------------------------------------------------
-- CHECK 2: active_weight_sanity
-- active_weight_pct should never exceed ±50% for any single holding.
-- Returns violating holdings.
-- ----------------------------------------------------------------------------
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
SELECT
    PORTFOLIO_ID,
    TICKER,
    WEIGHT_PCT,
    BENCHMARK_WEIGHT_PCT,
    ACTIVE_WEIGHT_PCT
FROM SILVER_PORTFOLIO_RISK
WHERE ABS(ACTIVE_WEIGHT_PCT) > 50
ORDER BY ABS(ACTIVE_WEIGHT_PCT) DESC;

-- ----------------------------------------------------------------------------
-- CHECK 3: price_currency
-- current_price must never be NULL or zero (a holding without a valid price
-- silently distorts market value and weights).
-- Returns violating holdings.
-- ----------------------------------------------------------------------------
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
SELECT
    PORTFOLIO_ID,
    TICKER,
    CURRENT_PRICE,
    MARKET_VALUE_USD,
    HOLDINGS_AS_OF
FROM SILVER_PORTFOLIO_RISK
WHERE CURRENT_PRICE IS NULL OR CURRENT_PRICE <= 0
ORDER BY PORTFOLIO_ID, TICKER;

-- ----------------------------------------------------------------------------
-- CHECK 4: return_bounds (FLAG ONLY — do not fail the pipeline on this)
-- 30d_return_pct should be between -80% and +300%. Outliers are flagged for
-- review, not treated as hard failures (synthetic/new listings can be extreme).
-- Returns flagged holdings; empty result = nothing to review.
-- ----------------------------------------------------------------------------
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
SELECT
    PORTFOLIO_ID,
    TICKER,
    CURRENT_PRICE,
    RETURN_30D_PCT,
    'REVIEW' AS severity           -- advisory, not a failure
FROM SILVER_PORTFOLIO_RISK
WHERE RETURN_30D_PCT IS NOT NULL
  AND (RETURN_30D_PCT < -80 OR RETURN_30D_PCT > 300)
ORDER BY ABS(RETURN_30D_PCT) DESC;

-- ----------------------------------------------------------------------------
-- CHECK 5: referential_integrity_price_history
-- Every ticker in SILVER_PORTFOLIO_RISK must have at least 20 trading days of
-- price data in ASSET_PRICES (enough history for 30d-return and vol calcs).
-- Returns tickers with insufficient price history.
-- ----------------------------------------------------------------------------
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
SELECT
    s.PORTFOLIO_ID,
    s.TICKER,
    COUNT(p.PRICE_DATE) AS price_days,
    'FAIL: <20 trading days' AS issue
FROM SILVER_PORTFOLIO_RISK s
LEFT JOIN ASSET_PRICES p
       ON s.TICKER = p.TICKER
GROUP BY s.PORTFOLIO_ID, s.TICKER
HAVING COUNT(p.PRICE_DATE) < 20
ORDER BY s.PORTFOLIO_ID, s.TICKER;

-- ----------------------------------------------------------------------------
-- CHECK 6: duplicate_grain
-- Each (PORTFOLIO_ID, TICKER) must appear exactly once.
-- Returns duplicated combinations.
-- ----------------------------------------------------------------------------
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
SELECT
    PORTFOLIO_ID,
    TICKER,
    COUNT(*)            AS occurrence_count,
    COUNT(DISTINCT ASSET_ID) AS distinct_asset_ids
FROM SILVER_PORTFOLIO_RISK
GROUP BY PORTFOLIO_ID, TICKER
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- ============================================================================
-- OPTIONAL: one-shot runner — run all six checks and get a single summary.
-- Each row: check name, violations found, pass/fail. Check 4 reported as
-- FLAG severity (advisory).
-- ============================================================================
-- USE DATABASE TEMP;
-- USE SCHEMA SGOKARAM_COCO_DEMO;
-- USE WAREHOUSE SE_WH;
WITH check1 AS (
    SELECT '1_weight_completeness' AS check_name, COUNT(*) AS violations
    FROM (
        SELECT PORTFOLIO_ID
        FROM SILVER_PORTFOLIO_RISK
        GROUP BY PORTFOLIO_ID
        HAVING ABS(SUM(WEIGHT_PCT) - 100) > 0.1
    )
),
check2 AS (
    SELECT '2_active_weight_sanity' AS check_name, COUNT(*) AS violations
    FROM SILVER_PORTFOLIO_RISK WHERE ABS(ACTIVE_WEIGHT_PCT) > 50
),
check3 AS (
    SELECT '3_price_currency' AS check_name, COUNT(*) AS violations
    FROM SILVER_PORTFOLIO_RISK WHERE CURRENT_PRICE IS NULL OR CURRENT_PRICE <= 0
),
check4 AS (
    SELECT '4_return_bounds_FLAG' AS check_name, COUNT(*) AS violations
    FROM SILVER_PORTFOLIO_RISK
    WHERE RETURN_30D_PCT IS NOT NULL
      AND (RETURN_30D_PCT < -80 OR RETURN_30D_PCT > 300)
),
check5 AS (
    SELECT '5_referential_integrity' AS check_name, COUNT(*) AS violations
    FROM (
        SELECT s.TICKER
        FROM SILVER_PORTFOLIO_RISK s
        LEFT JOIN ASSET_PRICES p ON s.TICKER = p.TICKER
        GROUP BY s.PORTFOLIO_ID, s.TICKER
        HAVING COUNT(p.PRICE_DATE) < 20
    )
),
check6 AS (
    SELECT '6_duplicate_grain' AS check_name, COUNT(*) AS violations
    FROM (
        SELECT PORTFOLIO_ID, TICKER
        FROM SILVER_PORTFOLIO_RISK
        GROUP BY PORTFOLIO_ID, TICKER
        HAVING COUNT(*) > 1
    )
)
SELECT
    check_name,
    violations,
    CASE
        WHEN check_name LIKE '4_%' AND violations > 0 THEN 'FLAG (review)'
        WHEN violations = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM (SELECT * FROM check1 UNION ALL SELECT * FROM check2 UNION ALL
      SELECT * FROM check3 UNION ALL SELECT * FROM check4 UNION ALL
      SELECT * FROM check5 UNION ALL SELECT * FROM check6)
ORDER BY check_name;
