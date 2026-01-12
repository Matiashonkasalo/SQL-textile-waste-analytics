
-- Countries with the largest reduction in textile waste treatment

WITH yearly_totals AS (
    SELECT
        country,
        year,
        SUM(amount) AS total_tonnes
    FROM textile_waste_clean
    GROUP BY country, year
),
yearly_change AS (
    SELECT
        country,
        year,
        total_tonnes,
        total_tonnes
            - LAG(total_tonnes) OVER (
                PARTITION BY country
                ORDER BY year
            ) AS yoy_change
    FROM yearly_totals
)

SELECT
    country,
    MIN(yoy_change) AS largest_reduction_tonnes
FROM yearly_change
WHERE yoy_change IS NOT NULL
GROUP BY country
ORDER BY largest_reduction_tonnes ASC
LIMIT 10;


-- Long-term change (first vs last year)

WITH yearly_totals AS (
    SELECT
        country,
        year,
        SUM(amount) AS total_tonnes
    FROM textile_waste_clean
    GROUP BY country, year
),
ranked_years AS (
    SELECT
        country,
        year,
        total_tonnes,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY year) AS rn_first,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY year DESC) AS rn_last
    FROM yearly_totals
)

SELECT
    country,
    MAX(CASE WHEN rn_first = 1 THEN total_tonnes END) AS first_year_tonnes,
    MAX(CASE WHEN rn_last = 1 THEN total_tonnes END) AS last_year_tonnes,
    MAX(CASE WHEN rn_last = 1 THEN total_tonnes END)
      - MAX(CASE WHEN rn_first = 1 THEN total_tonnes END) AS absolute_change
FROM ranked_years
GROUP BY country
ORDER BY absolute_change ASC;


-- Relative change (%) in textile waste treatment

WITH yearly_totals AS (
    SELECT
        country,
        year,
        SUM(amount) AS total_tonnes
    FROM textile_waste_clean
    GROUP BY country, year
),
bounds AS (
    SELECT
        country,
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM yearly_totals
    GROUP BY country
),
joined AS (
    SELECT
        y.country,
        y.year,
        y.total_tonnes,
        b.first_year,
        b.last_year
    FROM yearly_totals y
    JOIN bounds b USING (country)
)

SELECT
    country,
    MAX(CASE WHEN year = first_year THEN total_tonnes END) AS first_year,
    MAX(CASE WHEN year = last_year THEN total_tonnes END) AS last_year,
    ROUND(
        100.0 * (
            MAX(CASE WHEN year = last_year THEN total_tonnes END)
          - MAX(CASE WHEN year = first_year THEN total_tonnes END)
        )
        / NULLIF(MAX(CASE WHEN year = first_year THEN total_tonnes END), 0),
        2
    ) AS pct_change
FROM joined
GROUP BY country
ORDER BY pct_change ASC;


-- Volatility of textile waste treatment

WITH yearly_totals AS (
    SELECT
        country,
        year,
        SUM(amount) AS total_tonnes
    FROM textile_waste_clean
    GROUP BY country, year
)

SELECT
    country,
    ROUND(STDDEV(total_tonnes), 2) AS volatility
FROM yearly_totals
GROUP BY country
ORDER BY volatility DESC;


-- Treatment structure by country

SELECT
    country,
    treatment_type,
    SUM(amount) AS total_tonnes
FROM textile_waste_clean
GROUP BY country, treatment_type
ORDER BY country, total_tonnes DESC;


-- Long-term trend slope (tonnes per year)

WITH yearly_totals AS (
    SELECT
        country,
        year,
        SUM(amount) AS total_tonnes
    FROM textile_waste_clean
    GROUP BY country, year
)

SELECT
    country,
    ROUND(REGR_SLOPE(total_tonnes, year), 2) AS tonnes_per_year_trend
FROM yearly_totals
GROUP BY country
ORDER BY tonnes_per_year_trend ASC;


-- Contribution analysis by treatment type
-- How different treatment types contribute to long-term change

WITH yearly_totals AS (
    SELECT
        country,
        year,
        treatment_type,
        SUM(amount) AS total_tonnes
    FROM textile_waste_clean
    GROUP BY country, year, treatment_type
),
bounds AS (
    SELECT
        country,
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM yearly_totals
    GROUP BY country
),
first_last AS (
    SELECT
        y.country,
        y.treatment_type,
        MAX(CASE WHEN y.year = b.first_year THEN y.total_tonnes END) AS first_year_tonnes,
        MAX(CASE WHEN y.year = b.last_year THEN y.total_tonnes END) AS last_year_tonnes
    FROM yearly_totals y
    JOIN bounds b ON y.country = b.country
    GROUP BY y.country, y.treatment_type
)

SELECT
    country,
    treatment_type,
    last_year_tonnes - first_year_tonnes AS contribution_tonnes
FROM first_last
WHERE
    first_year_tonnes IS NOT NULL
    AND last_year_tonnes IS NOT NULL
ORDER BY country, contribution_tonnes ASC;
