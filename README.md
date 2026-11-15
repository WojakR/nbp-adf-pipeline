# NBP Exchange Rates - Azure Data Factory pipeline

Pipeline that loads daily NBP exchange rates (table A) into Azure:
NBP API -> ADLS Gen2 (raw JSON) -> Azure SQL Database.

Built to learn Azure Data Factory. Work in progress.

## Stack
- Azure Data Factory
- Azure Data Lake Storage Gen2
- Azure SQL Database (serverless)

## Database
- `stg` - staging table with rows from the latest load, truncated before each run
- `dbo` - target table with one rate per date and currency
- `ctl` - load state (watermark) and pipeline run log

`dbo.usp_merge_exchange_rates` upserts staging rows into the target table.
It stops with an error if staging has incomplete rows or conflicting duplicates,
and returns the number of inserted and updated rows.

## Setup
Run the scripts in `sql/` in numeric order on an Azure SQL Database.

## Testing
Run `tests/test_usp_merge_exchange_rates.sql` to check the merge procedure.
(dev only - it truncates the tables).

## Status
- [x] Azure resources
- [x] SQL schema and merge procedure
- [ ] Ingestion pipeline
- [ ] Incremental load + scheduling
- [ ] Logging and error handling