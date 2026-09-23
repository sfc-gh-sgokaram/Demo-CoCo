-- ============================================================
-- Finance Asset Management Demo - Setup Script
-- Target: TEMP.SGOKARAM_COCO_DEMO  |  Warehouse: SE_WH
-- Re-runnable: DROP IF EXISTS on all tables
-- ============================================================

USE DATABASE TEMP;
USE SCHEMA SGOKARAM_COCO_DEMO;
USE WAREHOUSE SE_WH;

-- ============================================================
-- DROP EXISTING TABLES
-- ============================================================
DROP TABLE IF EXISTS TRADE_HISTORY;
DROP TABLE IF EXISTS BENCHMARK_WEIGHTS;
DROP TABLE IF EXISTS ASSET_PRICES;
DROP TABLE IF EXISTS PORTFOLIO_HOLDINGS;

-- ============================================================
-- CREATE TABLES
-- ============================================================

CREATE TABLE PORTFOLIO_HOLDINGS (
    portfolio_id      VARCHAR(20),
    asset_id          VARCHAR(10),
    ticker            VARCHAR(10),
    asset_class       VARCHAR(30),
    sector            VARCHAR(30),
    quantity          NUMBER(12,2),
    market_value_usd  NUMBER(15,2),
    as_of_date        DATE
);

CREATE TABLE ASSET_PRICES (
    asset_id    VARCHAR(10),
    ticker      VARCHAR(10),
    price_date  DATE,
    close_price NUMBER(10,2),
    volume      BIGINT
);

CREATE TABLE BENCHMARK_WEIGHTS (
    benchmark_id   VARCHAR(20),
    benchmark_name VARCHAR(60),
    ticker         VARCHAR(10),
    weight_pct     NUMBER(8,4),
    as_of_date     DATE
);

CREATE TABLE TRADE_HISTORY (
    trade_id     VARCHAR(20),
    portfolio_id VARCHAR(20),
    ticker       VARCHAR(10),
    trade_type   VARCHAR(4),
    quantity     NUMBER(12,2),
    trade_price  NUMBER(10,2),
    trade_date   DATE
);

-- ============================================================
-- INSERT: PORTFOLIO_HOLDINGS
-- 3 portfolios × 20 tickers × 2 as-of dates = 120 rows
-- Prices basis: AAPL 185, MSFT 420, GOOGL 175, AMZN 195,
--               NVDA 125, META 560, TSLA 240, JPM 225, BAC 44,
--               GS 520, V 285, MA 475, JNJ 152, UNH 500, PFE 26,
--               XOM 112, CVX 155, PG 162, KO 69, WMT 86
-- ============================================================

INSERT INTO PORTFOLIO_HOLDINGS VALUES
-- ── BLK_CORE_EQ  2026-09-15 ──────────────────────────────
('BLK_CORE_EQ','AST_001','AAPL','Equity','Technology',             500.00,  92500.00,'2026-09-15'),
('BLK_CORE_EQ','AST_002','MSFT','Equity','Technology',             300.00, 126000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_003','GOOGL','Equity','Technology',            400.00,  70000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_004','AMZN','Equity','Technology',             350.00,  68250.00,'2026-09-15'),
('BLK_CORE_EQ','AST_005','NVDA','Equity','Technology',             600.00,  75000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_006','META','Equity','Technology',             200.00, 112000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_007','TSLA','Equity','Consumer Discretionary', 250.00,  60000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_008','JPM', 'Equity','Financials',             400.00,  90000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_009','BAC', 'Equity','Financials',             800.00,  35200.00,'2026-09-15'),
('BLK_CORE_EQ','AST_010','GS',  'Equity','Financials',             150.00,  78000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_011','V',   'Equity','Financials',             350.00,  99750.00,'2026-09-15'),
('BLK_CORE_EQ','AST_012','MA',  'Equity','Financials',             200.00,  95000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_013','JNJ', 'Equity','Healthcare',             400.00,  60800.00,'2026-09-15'),
('BLK_CORE_EQ','AST_014','UNH', 'Equity','Healthcare',             200.00, 100000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_015','PFE', 'Equity','Healthcare',            1200.00,  31200.00,'2026-09-15'),
('BLK_CORE_EQ','AST_016','XOM', 'Equity','Energy',                 500.00,  56000.00,'2026-09-15'),
('BLK_CORE_EQ','AST_017','CVX', 'Equity','Energy',                 350.00,  54250.00,'2026-09-15'),
('BLK_CORE_EQ','AST_018','PG',  'Equity','Consumer Staples',       400.00,  64800.00,'2026-09-15'),
('BLK_CORE_EQ','AST_019','KO',  'Equity','Consumer Staples',       700.00,  48300.00,'2026-09-15'),
('BLK_CORE_EQ','AST_020','WMT', 'Equity','Consumer Staples',       500.00,  43000.00,'2026-09-15'),
-- ── BLK_GROWTH  2026-09-15 ───────────────────────────────
('BLK_GROWTH','AST_001','AAPL','Equity','Technology',             1200.00, 222000.00,'2026-09-15'),
('BLK_GROWTH','AST_002','MSFT','Equity','Technology',              800.00, 336000.00,'2026-09-15'),
('BLK_GROWTH','AST_003','GOOGL','Equity','Technology',             900.00, 157500.00,'2026-09-15'),
('BLK_GROWTH','AST_004','AMZN','Equity','Technology',              750.00, 146250.00,'2026-09-15'),
('BLK_GROWTH','AST_005','NVDA','Equity','Technology',             2000.00, 250000.00,'2026-09-15'),
('BLK_GROWTH','AST_006','META','Equity','Technology',              500.00, 280000.00,'2026-09-15'),
('BLK_GROWTH','AST_007','TSLA','Equity','Consumer Discretionary',  600.00, 144000.00,'2026-09-15'),
('BLK_GROWTH','AST_008','JPM', 'Equity','Financials',              200.00,  45000.00,'2026-09-15'),
('BLK_GROWTH','AST_009','BAC', 'Equity','Financials',              300.00,  13200.00,'2026-09-15'),
('BLK_GROWTH','AST_010','GS',  'Equity','Financials',              100.00,  52000.00,'2026-09-15'),
('BLK_GROWTH','AST_011','V',   'Equity','Financials',              500.00, 142500.00,'2026-09-15'),
('BLK_GROWTH','AST_012','MA',  'Equity','Financials',              300.00, 142500.00,'2026-09-15'),
('BLK_GROWTH','AST_013','JNJ', 'Equity','Healthcare',              200.00,  30400.00,'2026-09-15'),
('BLK_GROWTH','AST_014','UNH', 'Equity','Healthcare',              300.00, 150000.00,'2026-09-15'),
('BLK_GROWTH','AST_015','PFE', 'Equity','Healthcare',              500.00,  13000.00,'2026-09-15'),
('BLK_GROWTH','AST_016','XOM', 'Equity','Energy',                  200.00,  22400.00,'2026-09-15'),
('BLK_GROWTH','AST_017','CVX', 'Equity','Energy',                  150.00,  23250.00,'2026-09-15'),
('BLK_GROWTH','AST_018','PG',  'Equity','Consumer Staples',        200.00,  32400.00,'2026-09-15'),
('BLK_GROWTH','AST_019','KO',  'Equity','Consumer Staples',        300.00,  20700.00,'2026-09-15'),
('BLK_GROWTH','AST_020','WMT', 'Equity','Consumer Staples',        200.00,  17200.00,'2026-09-15'),
-- ── BLK_VALUE  2026-09-15 ────────────────────────────────
('BLK_VALUE','AST_001','AAPL','Equity','Technology',               300.00,  55500.00,'2026-09-15'),
('BLK_VALUE','AST_002','MSFT','Equity','Technology',               200.00,  84000.00,'2026-09-15'),
('BLK_VALUE','AST_003','GOOGL','Equity','Technology',              150.00,  26250.00,'2026-09-15'),
('BLK_VALUE','AST_004','AMZN','Equity','Technology',               100.00,  19500.00,'2026-09-15'),
('BLK_VALUE','AST_005','NVDA','Equity','Technology',               200.00,  25000.00,'2026-09-15'),
('BLK_VALUE','AST_006','META','Equity','Technology',               100.00,  56000.00,'2026-09-15'),
('BLK_VALUE','AST_007','TSLA','Equity','Consumer Discretionary',   100.00,  24000.00,'2026-09-15'),
('BLK_VALUE','AST_008','JPM', 'Equity','Financials',              1000.00, 225000.00,'2026-09-15'),
('BLK_VALUE','AST_009','BAC', 'Equity','Financials',              2500.00, 110000.00,'2026-09-15'),
('BLK_VALUE','AST_010','GS',  'Equity','Financials',               400.00, 208000.00,'2026-09-15'),
('BLK_VALUE','AST_011','V',   'Equity','Financials',               600.00, 171000.00,'2026-09-15'),
('BLK_VALUE','AST_012','MA',  'Equity','Financials',               350.00, 166250.00,'2026-09-15'),
('BLK_VALUE','AST_013','JNJ', 'Equity','Healthcare',               800.00, 121600.00,'2026-09-15'),
('BLK_VALUE','AST_014','UNH', 'Equity','Healthcare',               300.00, 150000.00,'2026-09-15'),
('BLK_VALUE','AST_015','PFE', 'Equity','Healthcare',              3000.00,  78000.00,'2026-09-15'),
('BLK_VALUE','AST_016','XOM', 'Equity','Energy',                  1000.00, 112000.00,'2026-09-15'),
('BLK_VALUE','AST_017','CVX', 'Equity','Energy',                   800.00, 124000.00,'2026-09-15'),
('BLK_VALUE','AST_018','PG',  'Equity','Consumer Staples',         800.00, 129600.00,'2026-09-15'),
('BLK_VALUE','AST_019','KO',  'Equity','Consumer Staples',        1500.00, 103500.00,'2026-09-15'),
('BLK_VALUE','AST_020','WMT', 'Equity','Consumer Staples',         900.00,  77400.00,'2026-09-15'),
-- ── BLK_CORE_EQ  2026-08-29 (prior month snapshot) ───────
('BLK_CORE_EQ','AST_001','AAPL','Equity','Technology',             500.00,  90000.00,'2026-08-29'),
('BLK_CORE_EQ','AST_002','MSFT','Equity','Technology',             300.00, 123600.00,'2026-08-29'),
('BLK_CORE_EQ','AST_003','GOOGL','Equity','Technology',            400.00,  67200.00,'2026-08-29'),
('BLK_CORE_EQ','AST_004','AMZN','Equity','Technology',             350.00,  66850.00,'2026-08-29'),
('BLK_CORE_EQ','AST_005','NVDA','Equity','Technology',             600.00,  70800.00,'2026-08-29'),
('BLK_CORE_EQ','AST_006','META','Equity','Technology',             200.00, 108600.00,'2026-08-29'),
('BLK_CORE_EQ','AST_007','TSLA','Equity','Consumer Discretionary', 250.00,  62500.00,'2026-08-29'),
('BLK_CORE_EQ','AST_008','JPM', 'Equity','Financials',             400.00,  89200.00,'2026-08-29'),
('BLK_CORE_EQ','AST_009','BAC', 'Equity','Financials',             800.00,  34400.00,'2026-08-29'),
('BLK_CORE_EQ','AST_010','GS',  'Equity','Financials',             150.00,  75600.00,'2026-08-29'),
('BLK_CORE_EQ','AST_011','V',   'Equity','Financials',             350.00,  98700.00,'2026-08-29'),
('BLK_CORE_EQ','AST_012','MA',  'Equity','Financials',             200.00,  93200.00,'2026-08-29'),
('BLK_CORE_EQ','AST_013','JNJ', 'Equity','Healthcare',             400.00,  61600.00,'2026-08-29'),
('BLK_CORE_EQ','AST_014','UNH', 'Equity','Healthcare',             200.00,  98000.00,'2026-08-29'),
('BLK_CORE_EQ','AST_015','PFE', 'Equity','Healthcare',            1200.00,  30000.00,'2026-08-29'),
('BLK_CORE_EQ','AST_016','XOM', 'Equity','Energy',                 500.00,  57000.00,'2026-08-29'),
('BLK_CORE_EQ','AST_017','CVX', 'Equity','Energy',                 350.00,  54950.00,'2026-08-29'),
('BLK_CORE_EQ','AST_018','PG',  'Equity','Consumer Staples',       400.00,  64800.00,'2026-08-29'),
('BLK_CORE_EQ','AST_019','KO',  'Equity','Consumer Staples',       700.00,  47600.00,'2026-08-29'),
('BLK_CORE_EQ','AST_020','WMT', 'Equity','Consumer Staples',       500.00,  43500.00,'2026-08-29'),
-- ── BLK_GROWTH  2026-08-29 ───────────────────────────────
('BLK_GROWTH','AST_001','AAPL','Equity','Technology',             1200.00, 216000.00,'2026-08-29'),
('BLK_GROWTH','AST_002','MSFT','Equity','Technology',              800.00, 329600.00,'2026-08-29'),
('BLK_GROWTH','AST_003','GOOGL','Equity','Technology',             900.00, 151200.00,'2026-08-29'),
('BLK_GROWTH','AST_004','AMZN','Equity','Technology',              750.00, 143250.00,'2026-08-29'),
('BLK_GROWTH','AST_005','NVDA','Equity','Technology',             2000.00, 236000.00,'2026-08-29'),
('BLK_GROWTH','AST_006','META','Equity','Technology',              500.00, 271500.00,'2026-08-29'),
('BLK_GROWTH','AST_007','TSLA','Equity','Consumer Discretionary',  600.00, 150000.00,'2026-08-29'),
('BLK_GROWTH','AST_008','JPM', 'Equity','Financials',              200.00,  44600.00,'2026-08-29'),
('BLK_GROWTH','AST_009','BAC', 'Equity','Financials',              300.00,  12900.00,'2026-08-29'),
('BLK_GROWTH','AST_010','GS',  'Equity','Financials',              100.00,  50400.00,'2026-08-29'),
('BLK_GROWTH','AST_011','V',   'Equity','Financials',              500.00, 141000.00,'2026-08-29'),
('BLK_GROWTH','AST_012','MA',  'Equity','Financials',              300.00, 139800.00,'2026-08-29'),
('BLK_GROWTH','AST_013','JNJ', 'Equity','Healthcare',              200.00,  30800.00,'2026-08-29'),
('BLK_GROWTH','AST_014','UNH', 'Equity','Healthcare',              300.00, 147000.00,'2026-08-29'),
('BLK_GROWTH','AST_015','PFE', 'Equity','Healthcare',              500.00,  12500.00,'2026-08-29'),
('BLK_GROWTH','AST_016','XOM', 'Equity','Energy',                  200.00,  22800.00,'2026-08-29'),
('BLK_GROWTH','AST_017','CVX', 'Equity','Energy',                  150.00,  23550.00,'2026-08-29'),
('BLK_GROWTH','AST_018','PG',  'Equity','Consumer Staples',        200.00,  32400.00,'2026-08-29'),
('BLK_GROWTH','AST_019','KO',  'Equity','Consumer Staples',        300.00,  20400.00,'2026-08-29'),
('BLK_GROWTH','AST_020','WMT', 'Equity','Consumer Staples',        200.00,  17400.00,'2026-08-29'),
-- ── BLK_VALUE  2026-08-29 ────────────────────────────────
('BLK_VALUE','AST_001','AAPL','Equity','Technology',               300.00,  54000.00,'2026-08-29'),
('BLK_VALUE','AST_002','MSFT','Equity','Technology',               200.00,  82400.00,'2026-08-29'),
('BLK_VALUE','AST_003','GOOGL','Equity','Technology',              150.00,  25200.00,'2026-08-29'),
('BLK_VALUE','AST_004','AMZN','Equity','Technology',               100.00,  19100.00,'2026-08-29'),
('BLK_VALUE','AST_005','NVDA','Equity','Technology',               200.00,  23600.00,'2026-08-29'),
('BLK_VALUE','AST_006','META','Equity','Technology',               100.00,  54300.00,'2026-08-29'),
('BLK_VALUE','AST_007','TSLA','Equity','Consumer Discretionary',   100.00,  25000.00,'2026-08-29'),
('BLK_VALUE','AST_008','JPM', 'Equity','Financials',              1000.00, 223000.00,'2026-08-29'),
('BLK_VALUE','AST_009','BAC', 'Equity','Financials',              2500.00, 107500.00,'2026-08-29'),
('BLK_VALUE','AST_010','GS',  'Equity','Financials',               400.00, 201600.00,'2026-08-29'),
('BLK_VALUE','AST_011','V',   'Equity','Financials',               600.00, 169200.00,'2026-08-29'),
('BLK_VALUE','AST_012','MA',  'Equity','Financials',               350.00, 163100.00,'2026-08-29'),
('BLK_VALUE','AST_013','JNJ', 'Equity','Healthcare',               800.00, 123200.00,'2026-08-29'),
('BLK_VALUE','AST_014','UNH', 'Equity','Healthcare',               300.00, 147000.00,'2026-08-29'),
('BLK_VALUE','AST_015','PFE', 'Equity','Healthcare',              3000.00,  75000.00,'2026-08-29'),
('BLK_VALUE','AST_016','XOM', 'Equity','Energy',                  1000.00, 114000.00,'2026-08-29'),
('BLK_VALUE','AST_017','CVX', 'Equity','Energy',                   800.00, 125600.00,'2026-08-29'),
('BLK_VALUE','AST_018','PG',  'Equity','Consumer Staples',         800.00, 129600.00,'2026-08-29'),
('BLK_VALUE','AST_019','KO',  'Equity','Consumer Staples',        1500.00, 102000.00,'2026-08-29'),
('BLK_VALUE','AST_020','WMT', 'Equity','Consumer Staples',         900.00,  78300.00,'2026-08-29');

-- ============================================================
-- INSERT: ASSET_PRICES
-- 20 tickers × 30 trading days ending 2026-09-15 ≈ 600 rows
-- Price walks ±2% daily around base prices using UNIFORM
-- ============================================================
INSERT INTO ASSET_PRICES
WITH tickers AS (
    SELECT column1 AS asset_id, column2 AS ticker, column3::FLOAT AS base_price
    FROM VALUES
        ('AST_001','AAPL', 185.00),
        ('AST_002','MSFT', 420.00),
        ('AST_003','GOOGL',175.00),
        ('AST_004','AMZN', 195.00),
        ('AST_005','NVDA', 125.00),
        ('AST_006','META', 560.00),
        ('AST_007','TSLA', 240.00),
        ('AST_008','JPM',  225.00),
        ('AST_009','BAC',   44.00),
        ('AST_010','GS',   520.00),
        ('AST_011','V',    285.00),
        ('AST_012','MA',   475.00),
        ('AST_013','JNJ',  152.00),
        ('AST_014','UNH',  500.00),
        ('AST_015','PFE',   26.00),
        ('AST_016','XOM',  112.00),
        ('AST_017','CVX',  155.00),
        ('AST_018','PG',   162.00),
        ('AST_019','KO',    69.00),
        ('AST_020','WMT',   86.00)
),
date_seq AS (
    SELECT SEQ4() AS s FROM TABLE(GENERATOR(ROWCOUNT => 50))
),
trading_days AS (
    SELECT
        DATEADD('day', -s, '2026-09-15'::DATE) AS price_date,
        s AS seq_num
    FROM date_seq
    WHERE DAYOFWEEK(DATEADD('day', -s, '2026-09-15'::DATE)) NOT IN (0, 6)
    QUALIFY ROW_NUMBER() OVER (ORDER BY s ASC) <= 30
)
SELECT
    t.asset_id,
    t.ticker,
    d.price_date,
    ROUND(t.base_price * (0.980 + UNIFORM(0, 40, RANDOM()) / 1000.0), 2) AS close_price,
    UNIFORM(5000000, 80000000, RANDOM())                                   AS volume
FROM tickers t
CROSS JOIN trading_days d;

-- ============================================================
-- INSERT: BENCHMARK_WEIGHTS
-- 3 benchmarks × 20 tickers × 2 dates = 120 rows
-- Weights sum to exactly 100.00 per benchmark per date
-- ============================================================
INSERT INTO BENCHMARK_WEIGHTS VALUES
-- ── SP500_PROXY  2026-09-15  (sum = 100.00) ───────────────
('SP500_PROXY','S&P 500 Proxy','AAPL', 13.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','MSFT', 11.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','NVDA',  9.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','GOOGL', 6.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','AMZN',  6.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','META',  5.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','TSLA',  3.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','JPM',   5.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','V',     4.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','MA',    4.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','BAC',   2.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','GS',    2.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','UNH',   4.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','JNJ',   3.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','PFE',   2.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','XOM',   3.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','CVX',   3.00,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','PG',    4.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','KO',    3.50,'2026-09-15'),
('SP500_PROXY','S&P 500 Proxy','WMT',   3.00,'2026-09-15'),
-- ── NDX100_PROXY  2026-09-15  (sum = 100.00) ─────────────
('NDX100_PROXY','NASDAQ-100 Proxy','AAPL', 22.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','MSFT', 19.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','NVDA', 15.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','GOOGL',10.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','AMZN',  8.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','META',  7.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','TSLA',  5.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','V',     2.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','MA',    2.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','JPM',   1.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','BAC',   1.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','GS',    1.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','UNH',   1.00,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','JNJ',   0.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','PFE',   0.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','XOM',   0.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','CVX',   0.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','PG',    0.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','KO',    0.50,'2026-09-15'),
('NDX100_PROXY','NASDAQ-100 Proxy','WMT',   0.50,'2026-09-15'),
-- ── DJI_PROXY  2026-09-15  (sum = 100.00) ────────────────
('DJI_PROXY','Dow Jones Proxy','AAPL',  6.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','MSFT',  5.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','GOOGL', 3.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','AMZN',  1.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','NVDA',  1.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','META',  1.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','TSLA',  0.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','JPM',  10.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','GS',    8.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','V',     6.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','MA',    6.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','BAC',   5.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','JNJ',   7.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','UNH',   5.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','PFE',   4.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','XOM',   5.00,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','CVX',   4.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','PG',    7.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','KO',    5.50,'2026-09-15'),
('DJI_PROXY','Dow Jones Proxy','WMT',   7.00,'2026-09-15'),
-- ── SP500_PROXY  2026-08-29  (sum = 100.00; minor weight drift) ──
('SP500_PROXY','S&P 500 Proxy','AAPL', 13.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','MSFT', 11.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','NVDA',  9.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','GOOGL', 6.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','AMZN',  6.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','META',  5.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','TSLA',  3.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','JPM',   5.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','V',     4.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','MA',    4.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','BAC',   2.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','GS',    2.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','UNH',   4.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','JNJ',   3.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','PFE',   2.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','XOM',   3.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','CVX',   3.00,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','PG',    4.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','KO',    3.50,'2026-08-29'),
('SP500_PROXY','S&P 500 Proxy','WMT',   3.00,'2026-08-29'),
-- ── NDX100_PROXY  2026-08-29  (sum = 100.00) ─────────────
('NDX100_PROXY','NASDAQ-100 Proxy','AAPL', 23.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','MSFT', 18.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','NVDA', 15.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','GOOGL',10.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','AMZN',  8.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','META',  7.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','TSLA',  5.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','V',     2.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','MA',    2.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','JPM',   1.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','BAC',   1.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','GS',    1.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','UNH',   1.00,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','JNJ',   0.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','PFE',   0.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','XOM',   0.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','CVX',   0.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','PG',    0.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','KO',    0.50,'2026-08-29'),
('NDX100_PROXY','NASDAQ-100 Proxy','WMT',   0.50,'2026-08-29'),
-- ── DJI_PROXY  2026-08-29  (sum = 100.00) ────────────────
('DJI_PROXY','Dow Jones Proxy','AAPL',  6.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','MSFT',  5.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','GOOGL', 3.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','AMZN',  1.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','NVDA',  1.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','META',  1.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','TSLA',  0.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','JPM',  10.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','GS',    8.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','V',     6.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','MA',    6.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','BAC',   5.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','JNJ',   7.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','UNH',   5.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','PFE',   4.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','XOM',   5.00,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','CVX',   4.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','PG',    7.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','KO',    5.50,'2026-08-29'),
('DJI_PROXY','Dow Jones Proxy','WMT',   7.00,'2026-08-29');

-- ============================================================
-- INSERT: TRADE_HISTORY
-- 100 trades generated via GENERATOR
-- Portfolios cycle: BLK_CORE_EQ / BLK_GROWTH / BLK_VALUE
-- Tickers cycle across all 20; ~70% BUY / 30% SELL
-- Date range: last 90 days (2026-06-17 to 2026-09-15)
-- ============================================================
INSERT INTO TRADE_HISTORY
WITH raw AS (
    SELECT SEQ4() AS rn FROM TABLE(GENERATOR(ROWCOUNT => 100))
),
portfolios AS (
    SELECT 0 AS pid, 'BLK_CORE_EQ' AS portfolio_id UNION ALL
    SELECT 1,        'BLK_GROWTH'                   UNION ALL
    SELECT 2,        'BLK_VALUE'
),
tickers AS (
    SELECT column1 AS tid, column2 AS ticker, column3::FLOAT AS base_price
    FROM VALUES
        ( 0,'AAPL', 185.00),( 1,'MSFT', 420.00),( 2,'GOOGL',175.00),
        ( 3,'AMZN', 195.00),( 4,'NVDA', 125.00),( 5,'META', 560.00),
        ( 6,'TSLA', 240.00),( 7,'JPM',  225.00),( 8,'BAC',   44.00),
        ( 9,'GS',   520.00),(10,'V',    285.00),(11,'MA',   475.00),
        (12,'JNJ',  152.00),(13,'UNH',  500.00),(14,'PFE',   26.00),
        (15,'XOM',  112.00),(16,'CVX',  155.00),(17,'PG',   162.00),
        (18,'KO',    69.00),(19,'WMT',   86.00)
)
SELECT
    'TRD_' || LPAD((r.rn + 1)::VARCHAR, 5, '0')            AS trade_id,
    p.portfolio_id,
    t.ticker,
    CASE WHEN UNIFORM(1, 10, RANDOM()) <= 7 THEN 'BUY'
         ELSE 'SELL' END                                    AS trade_type,
    UNIFORM(1, 50, RANDOM()) * 10                           AS quantity,
    ROUND(t.base_price * (0.970 + UNIFORM(0, 60, RANDOM()) / 1000.0), 2) AS trade_price,
    DATEADD('day', -UNIFORM(0, 89, RANDOM()), '2026-09-15'::DATE)         AS trade_date
FROM raw r
JOIN portfolios p ON p.pid = r.rn % 3
JOIN tickers    t ON t.tid = r.rn % 20;

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'PORTFOLIO_HOLDINGS' AS tbl, COUNT(*) AS row_count FROM PORTFOLIO_HOLDINGS
UNION ALL
SELECT 'ASSET_PRICES',              COUNT(*)             FROM ASSET_PRICES
UNION ALL
SELECT 'BENCHMARK_WEIGHTS',         COUNT(*)             FROM BENCHMARK_WEIGHTS
UNION ALL
SELECT 'TRADE_HISTORY',             COUNT(*)             FROM TRADE_HISTORY;
