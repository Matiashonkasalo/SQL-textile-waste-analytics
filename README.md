# Textile Waste Treatment Analytics (EU)

This project analyzes long-term trends in textile waste treatment across selected European countries using official Eurostat data.  
The goal is to understand **how textile waste treatment volumes evolve over time**, how stable these trends are, and **which treatment methods drive observed changes**.

The project is implemented using **SQL (DuckDB)** and focuses on building a clean, well-structured analytics pipeline rather than visualization or dashboards.

---

##  Data Source

- **Source:** [Eurostat – Waste Statistics](https://ec.europa.eu/eurostat/databrowser/view/env_wastrt/default/table?lang=en)
- **Dataset:** Treatment of waste by waste category, hazardousness and waste management operations  
- **Unit:** Tonnes  
- **Time period:** 2010–2022 (varies by country)  
- **Countries included:** DE, DK, ES, FI, FR, NL, NO, SE, UK

Only observations related to **textile waste** (NACE Rev. 2 classification) were included.

---

##  Project Structure

```text
.
├── data/
│   └── textile_waste_treatment.csv    # Raw Eurostat data
├── sql/
│   ├── 01_staging.sql                 # Load and standardize raw data
│   ├── 02_clean.sql                   # Filter and prepare clean dataset
│   └── 03_analytics.sql               # Time-series analytics queries
├── db.duckdb                          # DuckDB database file
└── README.md
```

---

##  Data Pipeline

### 1. Staging (`01_staging.sql`)
- Load raw CSV data
- Select relevant columns
- Standardize column names
- Remove rows with missing observations

### 2. Cleaning (`02_clean.sql`)
- Filter to textile waste only
- Use tonnes as the unit of measure for maximum coverage
- Remove zero-valued observations (likely represent missing or non-reported values)
- Cast numeric values explicitly

**Result:** Clean dataset with **646 high-quality observations**

---

##  Analytics Overview

All analytics are implemented in SQL and focus on time-series reasoning and decomposition.

### Analyses Included

| Analysis | Description | 
|----------|-------------|
| **Yearly totals** | Aggregated volumes per country and year | 
| **Year-over-year change** | Short-term shocks and sudden reductions | 
| **Largest single-year reductions** | Biggest annual decrease per country | 
| **Long-term change** | First year vs last year comparison | 
| **Relative change (%)** | Normalized growth/decline rates | 
| **Volatility analysis** | Stability of treatment volumes | 
| **Trend slope** | Linear trend estimate (tonnes/year) | 
| **Contribution analysis** | Treatment type decomposition | 

---

##  Key Insights

### Treatment Volume Trends
- **Declining:** UK (-18.7%), Spain (-33.4%), Norway (-70.9%)
- **Growing:** France (+110%), Netherlands (+125%), Denmark (+493%)

### Volatility Patterns
- Larger countries (UK, DE, FR) show higher volatility
- Smaller countries (SE, NO, FI) display more stable patterns

### Treatment Methods
- **RCV_R_B** (material recovery for backfilling) dominates in most countries
- Spain shows significant **DSP_L** (landfill disposal) usage
- UK heavily concentrated in recycling operations (93% of total)

### Structural Shifts
- Long-term changes typically driven by shifts across **multiple treatment methods**
- Single treatment types rarely explain entire trend reversals

>  **Note:** These observations reflect patterns in the data and do not imply causal relationships.

---

##  How to Run

### Prerequisites
- [DuckDB](https://duckdb.org/) CLI or Python package

### Steps
```bash
# 1. Clone the repository
git clone https://github.com/Matiashonkasalo/textile-waste-analytics.git
cd textile-waste-analytics

# 2. Run the pipeline
duckdb db.duckdb < sql/01_staging.sql
duckdb db.duckdb < sql/02_clean.sql
duckdb db.duckdb < sql/03_analytics.sql

# Or run all at once
cat sql/*.sql | duckdb db.duckdb
```

---

##  Notes and Limitations

- **Reporting practices:** Changes may reflect differences in national reporting standards or classification updates
- **Data availability:** Time series length varies by country (some start later than 2010)
- **Trend assumptions:** Linear regression assumes constant rate of change, which may not hold for all countries
- **Scope:** Analysis focuses on treatment volumes, not textile consumption or waste generation
- **Zero values:** Removed as they likely represent non-reporting rather than true zeros

This project prioritizes **analytical reasoning** over policy evaluation or recommendations.

---

##  Technologies Used

- **DuckDB** – Fast analytical SQL database
- **SQL** – Window functions, CTEs, regression analysis
- **Eurostat** – Official European statistics

---

##  Treatment Type Codes

| Code | Description |
|------|-------------|
| TRT | Total treatment operations |
| RCV_R | Recovery - Recycling |
| RCV_R_B | Recovery - Recycling/Backfilling |
| RCV_E | Recovery - Energy recovery |
| DSP_L | Disposal - Landfill |
| DSP_L_OTH | Disposal - Landfill other |
| DSP_I | Disposal - Incineration |


