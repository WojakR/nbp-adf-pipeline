-- Target table: cleaned, deduplicated NBP table A mid rates.
-- One row per effective_date + currency_code. Loaded via MERGE from stg.

IF OBJECT_ID('dbo.exchange_rates') IS NULL
CREATE TABLE dbo.exchange_rates (
    effective_date  DATE           NOT NULL,
    table_no        VARCHAR(20)    NOT NULL,
    currency_code   CHAR(3)        NOT NULL,
    currency_name   NVARCHAR(100)  NOT NULL,
    mid_rate        DECIMAL(18,6)  NOT NULL,
    loaded_at       DATETIME2(0)   NOT NULL
        CONSTRAINT DF_exchange_rates_loaded_at DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)   NULL,

    CONSTRAINT PK_exchange_rates
        PRIMARY KEY(effective_date, currency_code),
    CONSTRAINT CK_exchange_rates_mid_rate_positive
        CHECK (mid_rate > 0)
);