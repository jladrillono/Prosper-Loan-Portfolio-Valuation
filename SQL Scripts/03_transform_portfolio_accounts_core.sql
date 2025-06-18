-- Drop table if it already exists to ensure a clean start for re-execution
DROP TABLE IF EXISTS public.portfolio_accounts_core;

-- Create the portfolio_accounts_core table
CREATE TABLE public.portfolio_accounts_core (
    listing_key VARCHAR(255) PRIMARY KEY,
    loan_key VARCHAR(255),
    loan_original_amount NUMERIC,
    lp_gross_principal_loss NUMERIC,
    loan_origination_date DATE,
    closed_date DATE,
    loan_status VARCHAR(255),
    charge_off_date DATE,
    fico_score_proxy INT,
    loan_age_at_charge_off_months INT,
    months_since_charge_off_at_valuation INT,
    prosper_score INT,          -- No NOT NULL specified, so it's nullable by default
    estimated_loss NUMERIC,     -- No NOT NULL specified, so it's nullable by default
    estimated_return NUMERIC,   -- No NOT NULL specified, so it's nullable by default
    segment_id VARCHAR(50)
);

-- Insert data into portfolio_accounts_core
INSERT INTO public.portfolio_accounts_core (
    listing_key,
    loan_key,
    loan_original_amount,
    lp_gross_principal_loss,
    loan_origination_date,
    closed_date,
    loan_status,
    charge_off_date,
    fico_score_proxy,
    loan_age_at_charge_off_months,
    months_since_charge_off_at_valuation,
    prosper_score,
    estimated_loss,
    estimated_return
)
SELECT
    s.listing_key,
    s.loan_key,
    -- Keep loan_original_amount defaulting to 0 for consistency if a 0 amount is a valid representation (e.g., small loans)
    COALESCE(NULLIF(TRIM(s.loan_original_amount), ''), '0')::NUMERIC,
    -- Keep lp_gross_principal_loss defaulting to 0 as it's filtered to be > 0 later
    COALESCE(NULLIF(TRIM(s.lp_gross_principal_loss), ''), '0')::NUMERIC,
    CAST(TRIM(s.loan_origination_date) AS DATE),
    CAST(TRIM(s.closed_date) AS DATE),
    TRIM(s.loan_status),

    -- charge_off_date: Using closed_date as per project documentation
    CAST(TRIM(s.closed_date) AS DATE) AS charge_off_date,
    -- fico_score_proxy: Calculate midpoint, defaulting to 0 if components are problematic
    (
        COALESCE(NULLIF(TRIM(s.credit_score_range_lower), ''), '0')::NUMERIC::INT +
        COALESCE(NULLIF(TRIM(s.credit_score_range_upper), ''), '0')::NUMERIC::INT
    ) / 2 AS fico_score_proxy,
    -- loan_age_at_charge_off_months: Calculate difference in months
    EXTRACT(YEAR FROM AGE(CAST(TRIM(s.closed_date) AS DATE), CAST(TRIM(s.loan_origination_date) AS DATE))) * 12 +
    EXTRACT(MONTH FROM AGE(CAST(TRIM(s.closed_date) AS DATE), CAST(TRIM(s.loan_origination_date) AS DATE))) AS loan_age_at_charge_off_months,
    -- months_since_charge_off_at_valuation: Calculate months from charge-off to valuation date
    EXTRACT(YEAR FROM AGE('2015-01-01'::DATE, CAST(TRIM(s.closed_date) AS DATE))) * 12 +
    EXTRACT(MONTH FROM AGE('2015-01-01'::DATE, CAST(TRIM(s.closed_date) AS DATE))) AS months_since_charge_off_at_valuation,
    -- MODIFIED: prosper_score - Cast to INT, NULL for empty/invalid strings
    CASE
        WHEN TRIM(s.prosper_score) = '' THEN NULL -- Treat empty strings as NULL
        WHEN TRIM(s.prosper_score) ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(TRIM(s.prosper_score) AS NUMERIC)::INT
        ELSE NULL -- Treat any other non-numeric text as NULL
    END AS prosper_score,
    -- MODIFIED: estimated_loss - Cast to NUMERIC, NULL for empty/invalid strings
    CASE
        WHEN TRIM(s.estimated_loss) = '' THEN NULL
        WHEN TRIM(s.estimated_loss) ~ '^-?\d+(\.\d+)?$' THEN CAST(TRIM(s.estimated_loss) AS NUMERIC)
        ELSE NULL
    END AS estimated_loss,
    -- MODIFIED: estimated_return - Cast to NUMERIC, NULL for empty/invalid strings
    CASE
        WHEN TRIM(s.estimated_return) = '' THEN NULL
        WHEN TRIM(s.estimated_return) ~ '^-?\d+(\.\d+)?$' THEN CAST(TRIM(s.estimated_return) AS NUMERIC)
        ELSE NULL
    END AS estimated_return
FROM
    public.staging_prosper s
WHERE
    TRIM(s.loan_status) IN ('Chargedoff', 'Defaulted')
    AND COALESCE(NULLIF(TRIM(s.lp_gross_principal_loss), ''), '0')::NUMERIC > 0
    AND TRIM(s.loan_origination_date) IS NOT NULL AND TRIM(s.loan_origination_date) != ''
    AND TRIM(s.closed_date) IS NOT NULL AND TRIM(s.closed_date) != '';

