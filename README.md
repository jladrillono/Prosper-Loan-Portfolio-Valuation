# Prosper Loan Portfolio Valuation Project

## Overview

This project focuses on valuing a historical portfolio of non-performing personal loans from Prosper, utilizing a segmented Discounted Cash Flow (DCF) model. The core of the project involves robust SQL-based data preparation, cleaning, feature engineering, and a granular segmentation strategy to feed into the valuation model.

## Project Goal

The primary goal is to value defined segments of a historical personal loan portfolio from the `prosperLoanData.csv` dataset, specifically focusing on 'Core Non-Performing' loans (those classified as 'Chargedoff' or 'Defaulted'). This valuation is achieved through a segmented Discounted Cash Flow (DCF) model that integrates industry benchmarks and allows for sensitivity analysis.

## Key Guiding Decisions & Parameters

* **Dataset:** `prosperLoanData.csv` (Prosper loans originated approximately between 2005-2014).
* **Primary Focus Portfolio:** 'Core Non-Performing' loans (`LoanStatus` = 'Chargedoff' or 'Defaulted').
* **Valuation Date:** January 1, 2015 (to align with the data vintage).
* **Forecast Horizon:** 84 months from the valuation date.
* **Score Proxy:** Midpoint of `CreditScoreRangeLower` and `CreditScoreRangeUpper`. `ProsperScore` is also utilized with specific handling for missing/invalid values.
* **Recovery Base:** `LP_GrossPrincipalLoss` for the 'Core Non-Performing' portfolio.
* **Key Model Assumptions (stored in `model_parameters` table):**
    * `valuation_date`: '2015-01-01'
    * `forecast_horizon`: '84' months
    * `base_case_discount_rate`: '0.20' (20% annual)
    * `base_case_collection_cost_percentage`: '0.25' (25% of gross recoveries)

## Database Schema (`debt_portfolio`)

The PostgreSQL database, `debt_portfolio`, is structured with the following key tables:

* **`staging_prosper`**:
    * **Purpose:** Stores raw, ingested data directly from `prosperLoanData.csv`.
    * **Columns:** All original columns from the CSV, stored as `TEXT`.
* **`portfolio_accounts_core`**:
    * **Purpose:** Contains cleaned, filtered, and feature-engineered data for 'Core Non-Performing' loans.
    * **Key Columns:** `listing_key` (PK), `loan_key`, `loan_original_amount` (NUMERIC), `lp_gross_principal_loss` (NUMERIC), `loan_origination_date` (DATE), `closed_date` (DATE), `loan_status` (VARCHAR), `charge_off_date` (DATE), `fico_score_proxy` (INT), `loan_age_at_charge_off_months` (INT), `months_since_charge_off_at_valuation` (INT), `prosper_score` (INT, nullable), `estimated_loss` (NUMERIC, nullable), `estimated_return` (NUMERIC, nullable), `segment_id` (VARCHAR).
* **`score_risk_mapping`**:
    * **Purpose:** Lookup table mapping FICO score bands to risk multipliers.
    * **Key Columns:** `score_band` (PK, VARCHAR), `risk_multiplier` (NUMERIC).
* **`recovery_curve_parameters`**:
    * **Purpose:** Stores segment-specific monthly recovery percentages over the forecast horizon.
    * **Key Columns:** `segment_id` (PK, VARCHAR), `month_number` (PK, INT), `recovery_percent` (NUMERIC).
* **`model_parameters`**:
    * **Purpose:** Configuration table for global DCF model assumptions.
    * **Key Columns:** `parameter_name` (PK, VARCHAR), `parameter_value` (VARCHAR), `description` (TEXT), `unit` (VARCHAR), `last_updated` (DATE).

## Important Notes on Data Handling & Current State

* **Snake\_case Naming:** All database tables and columns adhere to `snake_case` naming conventions for consistency.
* **Robust Casting:** Extensive SQL transformations handle data type conversions from `TEXT` to `NUMERIC`/`INT`/`DATE`, including robust management of empty strings and non-numeric values.
* **`prosper_score` Fix:** The `prosper_score` column now correctly reflects original values (1-10 range) with proper `NULL` handling for missing/non-numeric entries.
* **Initial Metrics:** The 'Core Non-Performing' portfolio currently shows a **total gross principal loss of ~$79.81M** and **forecasted gross recoveries (pre-cost) of ~$4.66M**, leading to a **gross recovery rate of ~5.84%**. This rate is observed to be lower than typical industry benchmarks (10-30%), which might indicate conservative recovery curve assumptions or specific portfolio characteristics requiring further analysis.
* **Loan Seasoning:** Forecasted gross recoveries are absent for months 1-9 in the DCF model, as all loans in the 'Core Non-Performing' portfolio are seasoned by at least 9 months at the January 1, 2015 valuation date.
* **Total NPV:** The Total Net Present Value (NPV) of the portfolio, as calculated in the DCF model, is approximately $1,721,975.13.

## Project Phases & SQL Scripts

The project follows a structured approach, with completed phases leading to a ready-to-use database for DCF modeling. The following SQL scripts (located in the project directory) are integral to the data pipeline:

1.  **`01_schema_definition.sql`**: Defines the schema for all necessary tables, including `staging_prosper`, `portfolio_accounts_core`, `score_risk_mapping`, `recovery_curve_parameters`, and `model_parameters`.
2.  **`02_loading_staging_prosper.sql`**: Contains the `COPY` command to load raw data from `prosperLoanData.csv` into the `staging_prosper` table. *(Note: Adjust `/path/to/your/prosperLoanData.csv` as needed for your environment.)*
3.  **`03_transform_portfolio_accounts_core.sql`**: Cleans, filters, and feature-engineers the raw data from `staging_prosper` to populate the `portfolio_accounts_core` table, focusing on 'Chargedoff' or 'Defaulted' loans.
4.  **`04_populate_lookup_tables.sql`**: Populates the `score_risk_mapping` and `model_parameters` tables with predefined risk multipliers and global DCF assumptions, respectively.
5.  **`05_assign_segment_ids.sql`**: Assigns `segment_id` to each loan in `portfolio_accounts_core` based on FICO score bands and `LoanOriginalAmount` quartiles (3x4 segmentation).
6.  **`06_populate_recovery_curves.sql`**: Populates the `recovery_curve_parameters` table with segment-specific monthly recovery percentages.
7.  **`07_calculate_key_metrics.sql`**: Calculates initial portfolio-level metrics, including total gross principal loss, forecasted gross recovery, and gross recovery rate.
8.  **`08_dcf_model_export_data.sql`**: Generates queries to extract global model parameters and segment-level monthly gross recoveries, formatted for import into a DCF spreadsheet model.
9.  **`Diagnostic Queries.sql`**: A collection of queries used for data validation, auditing, and exploration throughout the data preparation and transformation phases.

## How to Run & Interpret the Project

To set up and run this project:

1.  **Database Setup:** Ensure you have a PostgreSQL database instance accessible.
2.  **Schema and Table Creation:** Execute `01_schema_definition.sql` to create the necessary tables.
3.  **Data Ingestion:** Load your `prosperLoanData.csv` file into the `staging_prosper` table using the `COPY` command provided in `02_loading_staging_prosper.sql`. Remember to adjust the file path.
4.  **Data Transformation & Population:** Execute scripts `03_transform_portfolio_accounts_core.sql` through `06_populate_recovery_curves.sql` sequentially to clean, transform, and populate the core analytical tables and lookup tables.
5.  **Calculate Key Metrics:** Run `07_calculate_key_metrics.sql` to get a summary of the portfolio's gross losses, forecasted recoveries, and gross recovery rate.
6.  **DCF Model Input Generation:** Execute `08_dcf_model_export_data.sql` to generate the data needed for your DCF model. This script outputs data that should be imported into the 'Model\_Parameters' and 'Segment\_Monthly\_Gross\_Recoveries' sheets of your DCF spreadsheet (e.g., `Project_Discounted Cash Flow Base.xlsx`).
7.  **DCF Model Review:** The `Project_Discounted Cash Flow Base.xlsx - DCF_Model.csv` file directly reflects the calculated Discount Factors, Gross Recoveries, Collection Costs, Net Cash Flow, and the final Segment-level and Total Portfolio NPVs. Review this file to understand the monthly cash flow projections and the ultimate valuation.
8.  **Sensitivity Analysis Review:** The `Project_Discounted Cash Flow Base.xlsx - Sensitivity_Analysis.csv` file contains the results of the sensitivity analysis, which can be used to understand how changes in key assumptions (recovery rates, discount rates, collection costs) impact the portfolio's NPV.

The `Prosper Loan Portfolio Valuation_ Project Overview & Comprehensive Plan.docx` document provides a more comprehensive, granular roadmap and detailed project documentation.

## Contact

For any questions or further clarification, please reach out to me at LadrillonoJustin@Gmail.com.

