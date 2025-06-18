-- Drop table if it already exists to ensure a clean start for re-execution
DROP TABLE IF EXISTS public.score_risk_mapping;

-- Create the score_risk_mapping table
-- This table stores predefined FICO score bands and their corresponding
-- risk multipliers, used for adjusting recovery curves based on loan quality.
CREATE TABLE public.score_risk_mapping (
    score_band VARCHAR(50) PRIMARY KEY, -- Example: 'Subprime (<620)', 'Prime (680-719)'
    risk_multiplier NUMERIC(5,2) NOT NULL -- Multiplier applied to base recovery rates
);

-- Populate score_risk_mapping with example data based on project parameters.
-- These values are derived from research and assumptions (e.g., Step 5.4 in project plan).
INSERT INTO public.score_risk_mapping (score_band, risk_multiplier) VALUES
('subprime_<620', 0.80),         -- Lower recovery for subprime loans
('near_prime_620_679', 0.95),    -- Slightly lower than base recovery
('prime_680_719', 1.05),         -- Slightly higher than base recovery
('super_prime_720+', 1.20);      -- Higher recovery for super prime loans

-- Drop table if it already exists to ensure a clean start
DROP TABLE IF EXISTS public.model_parameters;

-- Create the model_parameters table
-- This table stores key global assumptions and parameters for the DCF model.
CREATE TABLE public.model_parameters (
    parameter_name VARCHAR(255) PRIMARY KEY, -- Name of the parameter (e.g., 'valuation_date')
    parameter_value VARCHAR(255),            -- Value of the parameter (stored as text for flexibility)
    description TEXT,                        -- Description of the parameter
    unit VARCHAR(50),                        -- Unit of the parameter (e.g., 'DATE', 'months', 'decimal')
    last_updated DATE                        -- Date the parameter was last updated
);

-- Populate model_parameters with the defined project assumptions.
INSERT INTO public.model_parameters (parameter_name, parameter_value, description, unit, last_updated) VALUES
('valuation_date', '2015-01-01', 'The date as of which the portfolio is valued.', 'DATE', CURRENT_DATE),
('forecast_horizon', '84', 'Number of months for cash flow projection.', 'months', CURRENT_DATE),
('base_case_discount_rate', '0.20', 'Annual discount rate for base case.', 'decimal', CURRENT_DATE),
('base_case_collection_cost_percentage', '0.25', 'Percentage of gross recoveries allocated to collection costs.', 'decimal', CURRENT_DATE);