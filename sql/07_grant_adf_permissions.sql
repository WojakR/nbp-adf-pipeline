-- Grants the Data Factory managed identity the minimum permissions
-- needed by the ingest pipeline. Later stages add their own grants
-- in new numbered scripts.
-- Must be run while connected with Microsoft Entra authentication.

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'adf-nbp-dev')
    CREATE USER [adf-nbp-dev] FROM EXTERNAL PROVIDER;

-- Staging load: Copy activity inserts rows, pre-copy script truncates the table
GRANT INSERT, ALTER ON OBJECT::stg.exchange_rates TO [adf-nbp-dev];

-- Merge into the target table; ownership chaining covers access to
-- stg.exchange_rates and dbo.exchange_rates inside the procedure
GRANT EXECUTE ON OBJECT::dbo.usp_merge_exchange_rates TO [adf-nbp-dev];