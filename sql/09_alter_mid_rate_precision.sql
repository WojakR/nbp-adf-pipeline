-- NBP publishes mid rates with up to 8 decimal places; DECIMAL(18,6) would round them.
SET XACT_ABORT ON;

BEGIN TRANSACTION;

IF EXISTS (SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('stg.exchange_rates') AND name = 'mid_rate' AND scale <> 8)
    ALTER TABLE stg.exchange_rates ALTER COLUMN mid_rate DECIMAL(18,8) NULL;

IF EXISTS (SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.exchange_rates') AND name = 'mid_rate' AND scale <> 8)
BEGIN
    ALTER TABLE dbo.exchange_rates DROP CONSTRAINT CK_exchange_rates_mid_rate_positive;
    ALTER TABLE dbo.exchange_rates ALTER COLUMN mid_rate DECIMAL(18,8) NOT NULL;
    ALTER TABLE dbo.exchange_rates ADD CONSTRAINT CK_exchange_rates_mid_rate_positive CHECK (mid_rate > 0);
END;

COMMIT;