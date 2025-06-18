CREATE SCHEMA IF NOT EXISTS "public";

DROP TABLE IF EXISTS model_parameters;

CREATE  TABLE "public".model_parameters ( 
	"parameter_name"     varchar(255)  NOT NULL  ,
	parameter_value      varchar(255)    ,
	description          text    ,
	unit                 varchar(50)    ,
	last_updated         date    ,
	CONSTRAINT model_parameters_pkey PRIMARY KEY ( "parameter_name" )
 );

DROP TABLE IF EXISTS portfolio_accounts_core;

CREATE  TABLE "public".portfolio_accounts_core ( 
	listing_key          varchar(255)  NOT NULL  ,
	loan_key             varchar(255)    ,
	loan_original_amount numeric    ,
	lp_gross_principal_loss numeric    ,
	loan_origination_date date    ,
	closed_date          date    ,
	loan_status          varchar(255)    ,
	charge_off_date      date    ,
	fico_score_proxy     integer    ,
	loan_age_at_charge_off_months integer    ,
	months_since_charge_off_at_valuation integer    ,
	prosper_score        integer    ,
	estimated_loss       numeric    ,
	estimated_return     numeric    ,
	segment_id           varchar(50)    ,
	CONSTRAINT portfolio_accounts_core_pkey PRIMARY KEY ( listing_key )
 );

DROP TABLE IF EXISTS public.recovery_curve_parameters;

CREATE  TABLE "public".recovery_curve_parameters ( 
	segment_id           varchar(50)  NOT NULL  ,
	month_number         integer  NOT NULL  ,
	recovery_percent     numeric(10,8)  NOT NULL  ,
	CONSTRAINT recovery_curve_parameters_pkey PRIMARY KEY ( segment_id, month_number )
 );

DROP TABLE IF EXISTS public.score_risk_mapping;

CREATE  TABLE "public".score_risk_mapping ( 
	score_band           varchar(50)  NOT NULL  ,
	risk_multiplier      numeric(5,2)  NOT NULL  ,
	CONSTRAINT score_risk_mapping_pkey PRIMARY KEY ( score_band )
 );

DROP TABLE IF EXISTS public.staging_prosper;

CREATE  TABLE "public".staging_prosper ( 
	listing_key          text    ,
	listing_number       text    ,
	listing_creation_date text    ,
	credit_grade         text    ,
	term                 text    ,
	loan_status          text    ,
	closed_date          text    ,
	borrower_apr         text    ,
	borrower_rate        text    ,
	lender_yield         text    ,
	estimated_effective_yield text    ,
	estimated_loss       text    ,
	estimated_return     text    ,
	prosper_rating_numeric text    ,
	prosper_rating_alpha text    ,
	prosper_score        text    ,
	listing_category_numeric text    ,
	borrower_state       text    ,
	occupation           text    ,
	employment_status    text    ,
	employment_status_duration text    ,
	is_borrower_homeowner text    ,
	currently_in_group   text    ,
	group_key            text    ,
	date_credit_pulled   text    ,
	credit_score_range_lower text    ,
	credit_score_range_upper text    ,
	first_recorded_credit_line text    ,
	current_credit_lines text    ,
	open_credit_lines    text    ,
	total_credit_lines_past_7_years text    ,
	open_revolving_accounts text    ,
	open_revolving_monthly_payment text    ,
	inquiries_last_6_months text    ,
	total_inquiries      text    ,
	current_delinquencies text    ,
	amount_delinquent    text    ,
	delinquencies_last_7_years text    ,
	public_records_last_10_years text    ,
	public_records_last_12_months text    ,
	revolving_credit_balance text    ,
	bankcard_utilization text    ,
	available_bankcard_credit text    ,
	total_trades         text    ,
	trades_never_delinquent_percentage text    ,
	trades_opened_last_6_months text    ,
	debt_to_income_ratio text    ,
	income_range         text    ,
	income_verifiable    text    ,
	stated_monthly_income text    ,
	loan_key             text    ,
	total_prosper_loans  text    ,
	total_prosper_payments_billed text    ,
	on_time_prosper_payments text    ,
	prosper_payments_less_than_one_month_late text    ,
	prosper_payments_one_month_plus_late text    ,
	prosper_principal_borrowed text    ,
	prosper_principal_outstanding text    ,
	scorex_change_at_time_of_listing text    ,
	loan_current_days_delinquent text    ,
	loan_first_defaulted_cycle_number text    ,
	loan_months_since_origination text    ,
	loan_number          text    ,
	loan_original_amount text    ,
	loan_origination_date text    ,
	loan_origination_quarter text    ,
	member_key           text    ,
	monthly_loan_payment text    ,
	lp_customer_payments text    ,
	lp_customer_principal_payments text    ,
	lp_interest_and_fees text    ,
	lp_service_fees      text    ,
	lp_collection_fees   text    ,
	lp_gross_principal_loss text    ,
	lp_net_principal_loss text    ,
	lp_non_principal_recovery_payments text    ,
	percent_funded       text    ,
	recommendations      text    ,
	investment_from_friends_count text    ,
	investment_from_friends_amount text    ,
	investors            text    
 );