SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'portfolio_accounts_core';


SELECT COUNT(*) FROM portfolio_accounts_core;

-- Diagnostic on original staging_prosper for prosper_score
SELECT
    prosper_score,
    COUNT(*) AS count_of_values
FROM staging_prosper
GROUP BY prosper_score
ORDER BY count_of_values DESC;

SELECT
    COUNT(*) FILTER (WHERE prosper_score IS NULL) AS original_null_count,
    COUNT(*) FILTER (WHERE TRIM(prosper_score) = '') AS original_empty_string_count,
    COUNT(*) FILTER (WHERE TRIM(prosper_score) ~ '^[0-9]+$') AS original_numeric_string_count,
    COUNT(*) FILTER (WHERE TRIM(prosper_score) IS NOT NULL AND TRIM(prosper_score) != '' AND TRIM(prosper_score) !~ '^[0-9]+$') AS original_other_non_numeric_count
FROM staging_prosper;

-- Sample check for specific loan date calculations
SELECT
    listing_key,
    loan_origination_date,
    closed_date,
    charge_off_date,
    loan_age_at_charge_off_months,
    months_since_charge_off_at_valuation
FROM portfolio_accounts_core
WHERE loan_age_at_charge_off_months < 0 OR months_since_charge_off_at_valuation < 0;

SELECT
    listing_key,
    loan_origination_date,
    closed_date,
    charge_off_date,
    loan_age_at_charge_off_months,
    months_since_charge_off_at_valuation
FROM portfolio_accounts_core;

SELECT
    MIN(prosper_score) AS min_prosper_score,
    MAX(prosper_score) AS max_prosper_score,
    COUNT(*) FILTER (WHERE prosper_score = 0) AS imputed_prosper_scores_count -- If 0 was the default for missing
FROM portfolio_accounts_core;

SELECT
    COUNT(*) FILTER (WHERE segment_id IS NULL) AS null_segment_id_count,
    COUNT(DISTINCT segment_id) AS unique_segments_count
FROM portfolio_accounts_core;

SELECT
    segment_id,
    COUNT(*) AS loan_count,
    MIN(fico_score_proxy) AS min_fico_in_segment,
    MAX(fico_score_proxy) AS max_fico_in_segment,
    MIN(loan_original_amount) AS min_loan_amt_in_segment,
    MAX(loan_original_amount) AS max_loan_amt_in_segment
FROM portfolio_accounts_core
GROUP BY segment_id
ORDER BY segment_id;

SELECT *
FROM score_risk_mapping;

SELECT DISTINCT rcp.segment_id
FROM recovery_curve_parameters rcp
LEFT JOIN portfolio_accounts_core pac ON rcp.segment_id = pac.segment_id
WHERE pac.segment_id IS NULL;

SELECT
    MIN(month_number) AS min_month,
    MAX(month_number) AS max_month,
    MIN(recovery_percent) AS min_recovery,
    MAX(recovery_percent) AS max_recovery
FROM recovery_curve_parameters;

-- Check distribution across bands (e.g., for segmentation verification)
SELECT
    CASE
        WHEN fico_score_proxy < 620 THEN '<620'
        WHEN fico_score_proxy BETWEEN 620 AND 679 THEN '620-679'
        WHEN fico_score_proxy BETWEEN 680 AND 719 THEN '680-719'
        WHEN fico_score_proxy >= 720 THEN '720+'
        ELSE 'N/A'
    END AS fico_band,
    COUNT(*) AS loan_count
FROM portfolio_accounts_core
GROUP BY 1
ORDER BY 1;

SELECT
    COUNT(*) FILTER (WHERE charge_off_date IS NULL) AS null_charge_off_dates,
    COUNT(*) FILTER (WHERE charge_off_date != closed_date) AS mismatch_charge_off_dates,
    MIN(loan_age_at_charge_off_months) AS min_loan_age,
    MAX(loan_age_at_charge_off_months) AS max_loan_age,
    MIN(months_since_charge_off_at_valuation) AS min_months_since_charge_off,
    MAX(months_since_charge_off_at_valuation) AS max_months_since_charge_off
FROM portfolio_accounts_core;

-- Diagnostic Query: Verify the data inserted into model_parameters
SELECT * FROM model_parameters;

-- Diagnostic queries for data preparation and transformation
SELECT DISTINCT loan_status
FROM portfolio_accounts_core;

SELECT
    MIN(lp_gross_principal_loss) AS min_gross_loss,
    MAX(lp_gross_principal_loss) AS max_gross_loss,
    AVG(lp_gross_principal_loss) AS avg_gross_loss,
    COUNT(*) FILTER (WHERE lp_gross_principal_loss <= 0) AS non_positive_losses_count
FROM portfolio_accounts_core;

SELECT
    MIN(fico_score_proxy) AS min_fico,
    MAX(fico_score_proxy) AS max_fico,
    AVG(fico_score_proxy) AS avg_fico,
    COUNT(*) AS total_loans
FROM portfolio_accounts_core;