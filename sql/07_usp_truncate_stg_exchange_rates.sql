-- Clears the staging table before each load.
-- EXECUTE AS OWNER lets callers truncate without ALTER permission on the table.
-- Kept static: no parameters or dynamic SQL, since it runs with owner rights.
CREATE OR ALTER PROCEDURE stg.usp_truncate_exchange_rates
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE stg.exchange_rates;
END;