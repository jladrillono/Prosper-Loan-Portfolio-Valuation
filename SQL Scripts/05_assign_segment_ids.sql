-- This ensures each loan is assigned to a specific segment for recovery curve application.
-- Assign segment_id to each loan in portfolio_accounts_core based on FICO and LoanOriginalAmount quartiles
WITH loan_amount_quartiles AS (
    SELECT
        listing_key,
        NTILE(4) OVER (ORDER BY loan_original_amount) AS loan_amount_quartile
    FROM
        public.portfolio_accounts_core
)
UPDATE public.portfolio_accounts_core pac
SET segment_id =
    CASE
        WHEN pac.fico_score_proxy < 620 THEN 'subprime_q' || laq.loan_amount_quartile
        WHEN pac.fico_score_proxy BETWEEN 620 AND 679 THEN 'near_prime_q' || laq.loan_amount_quartile
        WHEN pac.fico_score_proxy BETWEEN 680 AND 719 THEN 'prime_q' || laq.loan_amount_quartile
        WHEN pac.fico_score_proxy >= 720 THEN 'super_prime_q' || laq.loan_amount_quartile
        ELSE 'unknown_segment' -- Fallback for any unmapped FICO scores
    END
FROM loan_amount_quartiles laq
WHERE pac.listing_key = laq.listing_key;
