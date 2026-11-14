-- Staging: raw rows from the latest NBP load.
-- Truncated before each load (ADF pre-copy script), no PK on purpose.

IF OBJECT_ID('stg.exchange_rates') IS NULL
CREATE TABLE stg.exchange_rates (
    effective_date  DATE           NULL,
    table_no        VARCHAR(20)    NULL,
    currency_code   CHAR(3)        NULL,
    currency_name   NVARCHAR(100)  NULL,
    mid_rate        DECIMAL(18,6)  NULL
);