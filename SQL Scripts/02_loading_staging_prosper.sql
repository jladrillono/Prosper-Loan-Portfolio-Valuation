-- This command assumes the CSV file is in a location accessible by the PostgreSQL server,
-- or if run via psql, client-side access.
-- Adjust the path to prosperLoanData.csv as needed.
COPY public.staging_prosper FROM '/path/to/your/prosperLoanData.csv' DELIMITER ',' CSV HEADER;