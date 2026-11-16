-- DEV ONLY: Verifies effective permissions of the Data Factory identity.
-- NULL in any column means the object was not found: treat it as a failure, not as 0.

-- Capture tables before impersonation as adf-nbp-dev
-- Max length of QUOTENAME(schema) + '.' + QUOTENAME(table): 2 x 258 + 1
DECLARE @protected_tables TABLE (table_name NVARCHAR(517));

INSERT INTO @protected_tables (table_name)
SELECT QUOTENAME(s.name) + '.' + QUOTENAME(t.name)
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name IN ('dbo', 'ctl');

EXECUTE AS USER = 'adf-nbp-dev';

-- 1. Required by ingestion pipeline. Expected: all 1.
SELECT
    HAS_PERMS_BY_NAME('stg.exchange_rates', 'OBJECT', 'INSERT') AS stg_insert,
    HAS_PERMS_BY_NAME('stg.exchange_rates', 'OBJECT', 'ALTER') AS stg_alter,
    HAS_PERMS_BY_NAME('dbo.usp_merge_exchange_rates', 'OBJECT', 'EXECUTE') AS merge_execute;

-- 2. Must not drop the staging table or run arbitrary procedures. Expected: all 0.
SELECT
    HAS_PERMS_BY_NAME('stg.exchange_rates', 'OBJECT', 'CONTROL') AS stg_control,
    HAS_PERMS_BY_NAME('stg', 'SCHEMA', 'ALTER') AS stg_schema_alter,
    HAS_PERMS_BY_NAME('dbo', 'SCHEMA', 'EXECUTE') AS dbo_schema_execute;

-- 3. Must not modify any dbo or ctl table directly.
-- Expected: one row per dbo/ctl table (currently 3), all 0. Zero rows means the check did not run.
SELECT
    table_name,
    HAS_PERMS_BY_NAME(table_name, 'OBJECT', 'INSERT') AS can_insert,
    HAS_PERMS_BY_NAME(table_name, 'OBJECT', 'UPDATE') AS can_update,
    HAS_PERMS_BY_NAME(table_name, 'OBJECT', 'DELETE') AS can_delete,
    HAS_PERMS_BY_NAME(table_name, 'OBJECT', 'ALTER') AS can_alter
FROM @protected_tables;

REVERT;