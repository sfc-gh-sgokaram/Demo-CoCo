-- Complex Query: Portfolio Active Weight with Rolling 7-Day Returns
-- This query is used in Lab 2 (Step 4) for the CoCo explanation exercise.
-- Run this after completing Lab 1 (tables must exist in your personal schema).

WITH holdings_weight AS (
    SELECT
        h.portfolio_id,
        h.sector,
        h.ticker,
        h.market_value_usd,
        SUM(h.market_value_usd) OVER (PARTITION BY h.portfolio_id)          AS total_portfolio_value,
        ROUND(
            h.market_value_usd /
            SUM(h.market_value_usd) OVER (PARTITION BY h.portfolio_id) * 100
        , 2)                                                                  AS portfolio_weight_pct
    FROM PORTFOLIO_HOLDINGS h
    WHERE h.as_of_date = (SELECT MAX(as_of_date) FROM PORTFOLIO_HOLDINGS)
),

benchmark AS (
    SELECT
        ticker,
        ROUND(SUM(weight_pct), 4)                                            AS benchmark_weight_pct
    FROM BENCHMARK_WEIGHTS
    WHERE benchmark_name = 'S&P 500'
      AND as_of_date = (SELECT MAX(as_of_date) FROM BENCHMARK_WEIGHTS)
    GROUP BY ticker
),

price_returns AS (
    SELECT
        ticker,
        price_date,
        close_price,
        LAG(close_price, 7) OVER (PARTITION BY ticker ORDER BY price_date)   AS price_7d_ago,
        ROUND(
            (close_price - LAG(close_price, 7) OVER (PARTITION BY ticker ORDER BY price_date))
            / NULLIF(LAG(close_price, 7) OVER (PARTITION BY ticker ORDER BY price_date), 0)
            * 100
        , 2)                                                                  AS return_7d_pct
    FROM ASSET_PRICES
    WHERE price_date >= DATEADD(DAY, -14, CURRENT_DATE)
)

SELECT
    h.portfolio_id,
    h.sector,
    h.ticker,
    h.portfolio_weight_pct,
    COALESCE(b.benchmark_weight_pct, 0)                                       AS benchmark_weight_pct,
    ROUND(h.portfolio_weight_pct - COALESCE(b.benchmark_weight_pct, 0), 2)   AS active_weight_pct,
    CASE
        WHEN h.portfolio_weight_pct - COALESCE(b.benchmark_weight_pct, 0) >  2 THEN 'OVERWEIGHT'
        WHEN h.portfolio_weight_pct - COALESCE(b.benchmark_weight_pct, 0) < -2 THEN 'UNDERWEIGHT'
        ELSE 'NEUTRAL'
    END                                                                        AS position_tilt,
    p.return_7d_pct                                                            AS rolling_7d_return_pct
FROM holdings_weight h
LEFT JOIN benchmark       b ON h.ticker     = b.ticker
LEFT JOIN price_returns   p ON h.ticker     = p.ticker
                            AND p.price_date = CURRENT_DATE
ORDER BY ABS(h.portfolio_weight_pct - COALESCE(b.benchmark_weight_pct, 0)) DESC;
