-- Upsert NBP table A rates from staging into the target table.
-- Returns one row with counts of inserted and updated rows.
CREATE OR ALTER PROCEDURE dbo.usp_merge_exchange_rates
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- 1. Fail on incomplete rows (likely a mapping or source problem).
    IF EXISTS (
        SELECT 1
        FROM stg.exchange_rates
        WHERE effective_date IS NULL
            OR table_no IS NULL
            OR currency_code IS NULL
            OR currency_name IS NULL
            OR mid_rate IS NULL
    ) THROW 50001, 'Incomplete rows in stg.exchange_rates (NULL in a required column).', 1;

    -- 2. Fail on conflicting duplicates (same date + currency, different values).
    IF EXISTS (
        SELECT 1
        FROM stg.exchange_rates
        GROUP BY effective_date, currency_code
        HAVING COUNT(DISTINCT mid_rate) > 1
            OR COUNT(DISTINCT table_no) > 1
            OR COUNT(DISTINCT currency_name) > 1
    ) THROW 50002, 'Conflicting duplicates in stg.exchange_rates (same date and currency, different rate, table or currency name).', 1;

    DECLARE @changes TABLE (merge_action NVARCHAR(10));

    -- 3. Upsert distinct staging rows into target.
    MERGE INTO dbo.exchange_rates WITH (HOLDLOCK) AS t
    USING (
        SELECT DISTINCT effective_date, table_no, currency_code, currency_name, mid_rate
        FROM stg.exchange_rates
    ) AS s
        ON t.effective_date = s.effective_date
        AND t.currency_code = s.currency_code
    WHEN MATCHED AND (
        t.mid_rate <> s.mid_rate
        OR t.table_no <> s.table_no
        OR t.currency_name <> s.currency_name
    ) THEN
        UPDATE SET
            t.mid_rate = s.mid_rate,
            t.table_no = s.table_no,
            t.currency_name = s.currency_name,
            t.updated_at = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (effective_date, table_no, currency_code, currency_name, mid_rate)
        VALUES (s.effective_date, s.table_no, s.currency_code, s.currency_name, s.mid_rate)
    OUTPUT $action INTO @changes;

    -- 4. Report counts.
    SELECT
        COUNT(CASE WHEN merge_action = 'INSERT' THEN 1 END) AS rows_inserted,
        COUNT(CASE WHEN merge_action = 'UPDATE' THEN 1 END) AS rows_updated
    FROM @changes;
END;
