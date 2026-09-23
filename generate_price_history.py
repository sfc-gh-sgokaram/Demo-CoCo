"""
generate_price_history.py

Generates 2 years of realistic daily price data for every ticker in PORTFOLIO_HOLDINGS
and appends it to ASSET_PRICES without duplicating dates already present.

Usage:
    uv run generate_price_history.py
    # or: python generate_price_history.py  (with snowflake-snowpark-python installed)
"""

from __future__ import annotations

import numpy as np
import pandas as pd
from datetime import date, timedelta

from snowflake.snowpark import Session
from snowflake.snowpark.functions import col

# ---------------------------------------------------------------------------
# Target objects
# ---------------------------------------------------------------------------
DB        = "TEMP"
SCHEMA    = "SGOKARAM_COCO_DEMO"
WAREHOUSE = "SE_WH"

# ---------------------------------------------------------------------------
# Per-ticker seed configuration
# Realistic prices as of mid-2024 (the walk starts ~2 years before existing data).
# Tickers not listed here fall back to $100 / Technology.
# ---------------------------------------------------------------------------
TICKER_CONFIG: dict[str, dict] = {
    "AAPL":  {"start_price": 175.0,  "sector": "Technology"},
    "MSFT":  {"start_price": 380.0,  "sector": "Technology"},
    "GOOGL": {"start_price": 140.0,  "sector": "Technology"},
    "NVDA":  {"start_price": 480.0,  "sector": "Technology"},
    "META":  {"start_price": 370.0,  "sector": "Technology"},
    "AMZN":  {"start_price": 180.0,  "sector": "ConsumerDiscretionary"},
    "TSLA":  {"start_price": 200.0,  "sector": "ConsumerDiscretionary"},
    "V":     {"start_price": 270.0,  "sector": "Financials"},
    "JPM":   {"start_price": 185.0,  "sector": "Financials"},
    "GS":    {"start_price": 390.0,  "sector": "Financials"},
    "BAC":   {"start_price":  36.0,  "sector": "Financials"},
    "JNJ":   {"start_price": 160.0,  "sector": "Healthcare"},
    "AMGN":  {"start_price": 285.0,  "sector": "Healthcare"},
    "UNH":   {"start_price": 510.0,  "sector": "Healthcare"},
    "PG":    {"start_price": 150.0,  "sector": "ConsumerStaples"},
    "KO":    {"start_price":  60.0,  "sector": "ConsumerStaples"},
    "PEP":   {"start_price": 175.0,  "sector": "ConsumerStaples"},
    "XOM":   {"start_price": 105.0,  "sector": "Energy"},
    "CVX":   {"start_price": 150.0,  "sector": "Energy"},
    "LIN":   {"start_price": 440.0,  "sector": "Materials"},
}

# Daily drift (mu) and sector correlation coefficient
SECTOR_PARAMS: dict[str, dict] = {
    "Technology":            {"mu":  0.00040, "corr": 0.60},
    "Financials":            {"mu":  0.00025, "corr": 0.55},
    "Healthcare":            {"mu":  0.00015, "corr": 0.40},
    "ConsumerStaples":       {"mu":  0.00010, "corr": 0.45},
    "ConsumerDiscretionary": {"mu":  0.00030, "corr": 0.52},
    "Energy":                {"mu":  0.00012, "corr": 0.58},
    "Materials":             {"mu":  0.00018, "corr": 0.48},
}

SIGMA    = 0.015          # daily volatility (~1.5%)
VOL_MIN  = 10_000_000
VOL_MAX  = 100_000_000

# ---------------------------------------------------------------------------
# Price generator
# ---------------------------------------------------------------------------

def generate_prices(asset_id: str, ticker: str,
                    start: date, end: date) -> pd.DataFrame:
    """
    Simulate daily CLOSE_PRICE and VOLUME via geometric Brownian motion.
    Uses a sector common-factor model so tickers in the same sector are correlated.
    Prices are guaranteed positive by construction (exponential of returns).
    """
    cfg    = TICKER_CONFIG.get(ticker, {"start_price": 100.0, "sector": "Technology"})
    sector = cfg["sector"]
    params = SECTOR_PARAMS.get(sector, SECTOR_PARAMS["Technology"])
    mu, corr = params["mu"], params["corr"]

    biz_days = pd.bdate_range(start=start, end=end)
    n = len(biz_days)
    if n == 0:
        return pd.DataFrame()

    # Deterministic seed from ticker name so re-runs produce identical data
    rng = np.random.default_rng(seed=abs(hash(ticker)) % (2 ** 31))

    # Two independent shocks → sector-correlated return
    sector_shock = rng.normal(0.0, SIGMA, n)
    idio_shock   = rng.normal(0.0, SIGMA, n)
    daily_ret    = mu + corr * sector_shock + np.sqrt(1.0 - corr ** 2) * idio_shock

    # GBM: S_t = S_{t-1} * exp(r - 0.5σ²)   ← Itô correction keeps E[S_t] on drift
    log_factors = daily_ret - 0.5 * SIGMA ** 2
    prices      = np.empty(n)
    prices[0]   = cfg["start_price"] * np.exp(log_factors[0])
    for i in range(1, n):
        prices[i] = prices[i - 1] * np.exp(log_factors[i])

    volumes = rng.integers(VOL_MIN, VOL_MAX + 1, size=n).astype(int)

    return pd.DataFrame({
        "ASSET_ID":    asset_id,
        "TICKER":      ticker,
        "PRICE_DATE":  pd.to_datetime(biz_days).date,
        "CLOSE_PRICE": np.round(prices, 2),
        "VOLUME":      volumes,
    })


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------

def run(session: Session) -> None:
    # 1. Determine the generation window
    #    - end   = day before the earliest existing price (no gap, no overlap)
    #    - start = 2 years before that
    row = session.sql(
        f"SELECT MIN(PRICE_DATE) AS MIN_DATE FROM {DB}.{SCHEMA}.ASSET_PRICES"
    ).collect()[0]
    earliest_existing: date = row["MIN_DATE"]
    gen_end   = earliest_existing - timedelta(days=1)
    gen_start = earliest_existing - timedelta(days=2 * 365 + 1)   # ~2 years

    print(f"Generation window  : {gen_start}  →  {gen_end}")

    # 2. Read distinct (ASSET_ID, TICKER) from PORTFOLIO_HOLDINGS
    holdings_pd = (
        session.table(f"{DB}.{SCHEMA}.PORTFOLIO_HOLDINGS")
        .select("ASSET_ID", "TICKER")
        .distinct()
        .to_pandas()
    )
    tickers = holdings_pd["TICKER"].tolist()
    print(f"Tickers to process : {len(tickers)}  →  {tickers}")

    # 3. Generate synthetic price history in Python
    frames: list[pd.DataFrame] = []
    for _, row in holdings_pd.iterrows():
        df = generate_prices(row["ASSET_ID"], row["TICKER"], gen_start, gen_end)
        if not df.empty:
            frames.append(df)

    if not frames:
        print("No rows generated. Exiting.")
        return

    new_pd = pd.concat(frames, ignore_index=True)
    print(f"Generated rows     : {len(new_pd):,}  ({len(tickers)} tickers × ~{len(new_pd)//len(tickers)} days)")

    # 4. Convert to Snowpark DataFrame and deduplicate against existing data
    new_sp   = session.create_dataframe(new_pd)
    existing = (
        session.table(f"{DB}.{SCHEMA}.ASSET_PRICES")
        .select(col("ASSET_ID").alias("EX_ASSET_ID"),
                col("PRICE_DATE").alias("EX_PRICE_DATE"))
    )
    to_insert = new_sp.join(
        existing,
        (new_sp["ASSET_ID"]   == existing["EX_ASSET_ID"]) &
        (new_sp["PRICE_DATE"] == existing["EX_PRICE_DATE"]),
        join_type="anti",
    ).select("ASSET_ID", "TICKER", "PRICE_DATE", "CLOSE_PRICE", "VOLUME")

    rows_net = to_insert.count()
    print(f"Rows after dedup   : {rows_net:,}")

    if rows_net == 0:
        print("All dates already present in ASSET_PRICES — nothing appended.")
        return

    # 5. Append to ASSET_PRICES
    to_insert.write.mode("append").save_as_table(f"{DB}.{SCHEMA}.ASSET_PRICES")

    # 6. Verify
    total = session.table(f"{DB}.{SCHEMA}.ASSET_PRICES").count()
    print(f"\nDone. ASSET_PRICES now contains {total:,} rows.")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    session = (
        Session.builder
        .config("connection_name", "SNOWHOUSE")
        .create()
    )
    session.use_database(DB)
    session.use_schema(SCHEMA)
    session.use_warehouse(WAREHOUSE)
    try:
        run(session)
    finally:
        session.close()
