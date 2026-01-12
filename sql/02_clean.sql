


-- 02_clean.sql
-- Clean textile waste data (tonnes), excluding zero-values

CREATE OR REPLACE TABLE textile_waste_clean AS
SELECT
    country,
    year,
    treatment_type,
    CAST(amount AS DOUBLE) AS amount
FROM textile_waste_staging
WHERE
    waste_category = 'Textile wastes'
    AND unit = 'Tonne'
    AND TRY_CAST(amount AS DOUBLE) IS NOT NULL
    AND CAST(amount AS DOUBLE) > 0
    AND year IS NOT NULL;
