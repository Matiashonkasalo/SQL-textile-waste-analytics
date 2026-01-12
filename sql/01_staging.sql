

-- 01_staging.sql
-- Stage textile waste treatment data from Eurostat (SDMX-CSV)

CREATE OR REPLACE TABLE textile_waste_staging AS
SELECT
    geo AS country, 
    CAST(TIME_PERIOD AS INTEGER) AS year,
    wst_oper AS treatment_type,
    "waste categories" AS waste_category, 
    "Unit of measure" AS unit, 
    OBS_VALUE AS amount
FROM read_csv_auto('data/textile_waste_treatment.csv')
WHERE
    OBS_VALUE IS NOT NULL;
