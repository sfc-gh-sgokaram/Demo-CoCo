# Step 2 — AI-Assisted Data Generation

**Phase:** DESIGN  
**Time:** ~5 minutes

> **The pitch:** The team needs to extend their test dataset — 30 days of prices isn't enough to build meaningful risk analytics. CoCo generates a Snowpark Python pipeline that produces realistic, schema-consistent data with a single natural-language prompt. No brittle scripts, no manual CSV prep.

---

## What You'll Showcase

- `$snowpark Development` skill for production-quality Snowpark Python generation
- CoCo understanding schema relationships and generating constraint-respecting data
- Privacy-safe transformation patterns (no real client data needed)
- Automatic data validation after generation

---

## Demo Prompts

### 2.1 — Ask CoCo to generate extended price history

```
I need to extend the ASSET_PRICES table with 2 years of historical daily price data
for all tickers currently in PORTFOLIO_HOLDINGS.


1. Reads the distinct tickers from PORTFOLIO_HOLDINGS
2. Generates 2 years of realistic daily OHLCV data per ticker
   - Use realistic starting prices for each ticker (AAPL ~$175, MSFT ~$380, etc.)
   - Apply ~1.5% daily random walk with sector-correlated drift
   - Volume: 10M–100M shares per day with weekend/holiday gaps removed
3. Appends the new rows to ASSET_PRICES without duplicating existing dates


Constraints:
- Prices must always be positive
- ASSET_PRICES already has 30 days of data — do not overwrite it
```

| What to look for |
|---|
| The `$snowpark Development` skill produces structured, commented Snowpark Python — not a one-liner |
| CoCo generates realistic sector-correlated drift, not just random noise |
| The INSERT logic deduplicates cleanly against existing data |

---

### 2.2 — Execute the pipeline

```
Execute generate_price_history.py.
Then verify the results:
- How many rows are now in ASSET_PRICES?
- What is the date range?
- Show me the 30-day return for AAPL and NVDA using the newly generated data.
```

| What to look for |
|---|
| Pipeline runs and populates without errors |
| CoCo runs the verification queries automatically after execution |
| Return calculation confirms the data is statistically reasonable |

---

### 2.3 — Generate a RISK_FACTORS table (bonus, if time permits)

```
The risk team also needs a RISK_FACTORS table capturing factor exposure per ticker.
Create the table and generate synthetic data with these columns:
- ticker, factor_date, beta_to_sp500, duration_years, volatility_30d, momentum_score

Use realistic ranges:
- beta: 0.5–2.5 (higher for tech, lower for utilities)
- volatility: 0.12–0.60 annualised
- momentum_score: -1.0 to 1.0

Generate one row per ticker per week for the last 2 years.
Save to generate_risk_factors.py and execute it.
```

| What to look for |
|---|
| CoCo respects the domain constraints (beta ranges per sector) without being reminded |
| The generated data would be usable in a real risk model, not just dummy values |

---

## Success Criteria

- [ ] `generate_price_history.py` created and runs without errors
- [ ] ASSET_PRICES grows from ~2,000 rows to ~15,000+ rows (20 tickers × 2 years)
- [ ] Date range spans 2 years of trading days
- [ ] Return calculation returns a plausible result

---

*Proceed to → [Step 3 — Build](./Step3-Build.md)*
