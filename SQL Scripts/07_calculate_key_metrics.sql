WITH PortfolioLosses AS (
    -- Calculate the total gross principal loss for the 'Core Non-Performing' portfolio
    SELECT
        SUM(lp_gross_principal_loss) AS total_gross_principal_loss
    FROM
        public.portfolio_accounts_core
),
ForecastedRecoveries AS (
    -- Calculate the forecasted gross recovery for each loan over its remaining forecast horizon
    SELECT
        SUM(
            pac.lp_gross_principal_loss * rcp.recovery_percent
        ) AS forecasted_gross_recovery
    FROM
        public.portfolio_accounts_core pac
    JOIN
        public.recovery_curve_parameters rcp
        ON pac.segment_id = rcp.segment_id
    WHERE
        -- Only consider recovery months that are AFTER the loan's months_since_charge_off_at_valuation
        -- and within the total 84-month forecast horizon.
        rcp.month_number > pac.months_since_charge_off_at_valuation
        AND rcp.month_number <= (SELECT CAST(parameter_value AS INT) FROM public.model_parameters WHERE parameter_name = 'forecast_horizon')
)
-- Final selection: Combine results to get all three metrics
SELECT
    pl.total_gross_principal_loss,
    fr.forecasted_gross_recovery,
    -- Calculate the gross recovery rate
    (fr.forecasted_gross_recovery / pl.total_gross_principal_loss) AS gross_recovery_rate
FROM
    PortfolioLosses pl,
    ForecastedRecoveries fr;