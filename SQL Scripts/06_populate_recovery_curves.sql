-- Drop table if it already exists to ensure a clean start
DROP TABLE IF EXISTS public.recovery_curve_parameters;

-- Create the recovery_curve_parameters table
CREATE TABLE public.recovery_curve_parameters (
    segment_id VARCHAR(50) NOT NULL,
    month_number INT NOT NULL,
    recovery_percent NUMERIC(10,8) NOT NULL,
    PRIMARY KEY (segment_id, month_number)
);

-- Populate recovery_curve_parameters
INSERT INTO public.recovery_curve_parameters (segment_id, month_number, recovery_percent)
SELECT
    DISTINCT pac.segment_id,
    generate_series(1, 84) AS month_number,
    -- Base monthly recovery rate * risk multiplier * exponential decay factor
    (0.005 * srm.risk_multiplier * EXP(-0.02 * generate_series(1, 84))) AS recovery_percent
FROM
    public.portfolio_accounts_core pac
JOIN
    public.score_risk_mapping srm ON
    -- Join condition to link FICO proxy to risk multiplier bands for each segment
    (pac.fico_score_proxy < 620 AND srm.score_band = 'subprime_<620') OR
    (pac.fico_score_proxy BETWEEN 620 AND 679 AND srm.score_band = 'near_prime_620_679') OR
    (pac.fico_score_proxy BETWEEN 680 AND 719 AND srm.score_band = 'prime_680_719') OR
    (pac.fico_score_proxy >= 720 AND srm.score_band = 'super_prime_720+')
GROUP BY
    pac.segment_id, srm.risk_multiplier, generate_series(1, 84)
ORDER BY
    pac.segment_id, month_number;
