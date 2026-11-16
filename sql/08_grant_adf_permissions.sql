-- Grants the Data Factory managed identity the minimum permissions
-- needed by the ingest pipeline. Later stages add their own grants
-- in new numbered scripts.
-- Must be run while connected with Microsoft Entra authentication.

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'adf-nbp-dev')
    CREATE USER [adf-nbp-dev] FROM EXTERNAL PROVIDER;

-- Copy activity loads raw rows into staging
GRANT INSERT ON OBJECT::stg.exchange_rates TO [adf-nbp-dev];

-- Pre-copy script clears staging through the procedure (no ALTER needed)
GRANT EXECUTE ON OBJECT::stg.usp_truncate_exchange_rates TO [adf-nbp-dev];

-- Merge into the target table; ownership chaining covers table access
GRANT EXECUTE ON OBJECT::dbo.usp_merge_exchange_rates TO [adf-nbp-dev];