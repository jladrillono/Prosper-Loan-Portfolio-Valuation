-- Query to extract global model parameters.
-- This result will be imported into the 'Model_Parameters' sheet in Google Sheets.
SELECT parameter_name, parameter_value
FROM public.model_parameters;

-- Query to generate segment-level monthly gross recoveries, accounting for individual loan seasoning.
-- This result will be imported into the 'Segment_Monthly_Gross_Recoveries' sheet in Google Sheets.
SELECT
    pac.segment_id,
    rcp.month_number AS forecast_month,
    SUM(pac.lp_gross_principal_loss * rcp.recovery_percent) AS gross_recovery_for_month
FROM
    public.portfolio_accounts_core pac
JOIN
    public.recovery_curve_parameters rcp
    ON pac.segment_id = rcp.segment_id
WHERE
    -- Ensure we only apply recovery_percent for months relevant to the loan's seasoning.
    -- rcp.month_number represents the month ON THE RECOVERY CURVE.
    -- We need to shift this by the loan's existing seasoning at valuation.
    -- So, if a loan is 5 months seasoned, its first recovery month will use rcp.month_number 6, etc.
    rcp.month_number >= pac.months_since_charge_off_at_valuation + 1
    AND rcp.month_number <= (SELECT CAST(parameter_value AS INT) FROM public.model_parameters WHERE parameter_name = 'forecast_horizon')
GROUP BY
    pac.segment_id,
    rcp.month_number
ORDER BY
    pac.segment_id,
    rcp.month_number;