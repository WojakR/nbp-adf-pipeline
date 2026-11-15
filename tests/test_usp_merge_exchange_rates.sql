-- Manual test for dbo.usp_merge_exchange_rates.
-- DEV ONLY: truncates stg and dbo tables.
-- Can be run as a whole: blocks are separate batches,
-- so the expected errors in D and E do not stop the remaining tests.
-- Expected results are in the comment above each block.

-- A: valid data -> rows_inserted = 2, rows_updated = 0
TRUNCATE TABLE stg.exchange_rates;
INSERT INTO stg.exchange_rates VALUES
    ('2026-11-12', '221/A/NBP/2026', 'USD', N'dolar amerykański', 3.95),
    ('2026-11-12', '221/A/NBP/2026', 'EUR', N'euro', 4.25);
EXEC dbo.usp_merge_exchange_rates;
GO

-- B: same data again -> 0, 0 (idempotency)
EXEC dbo.usp_merge_exchange_rates
GO

-- C: identical duplicate -> 0, 0, no error
INSERT INTO stg.exchange_rates VALUES
    ('2026-11-12', '221/A/NBP/2026', 'USD', N'dolar amerykański', 3.95);
EXEC dbo.usp_merge_exchange_rates;
GO

-- D: conflicting duplicate -> error 50002
INSERT INTO stg.exchange_rates VALUES
    ('2026-11-12', '221/A/NBP/2026', 'USD', N'dolar amerykański', 3.99);
EXEC dbo.usp_merge_exchange_rates;
GO

-- E: NULL in a required column -> error 50001
TRUNCATE TABLE stg.exchange_rates;
INSERT INTO stg.exchange_rates VALUES
    ('2026-11-12', '221/A/NBP/2026', 'USD', N'dolar amerykański', NULL);
EXEC dbo.usp_merge_exchange_rates;
GO

-- F: rate correction -> 0, 1 (USD gets updated_at, EUR does not)
TRUNCATE TABLE stg.exchange_rates;
INSERT INTO stg.exchange_rates VALUES
    ('2026-11-12', '221/A/NBP/2026', 'USD', N'dolar amerykański', 3.96);
EXEC dbo.usp_merge_exchange_rates;
SELECT * FROM dbo.exchange_rates;
GO

-- Cleanup
TRUNCATE TABLE stg.exchange_rates;
TRUNCATE TABLE dbo.exchange_rates;
GO