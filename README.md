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

`stg.usp_truncate_exchange_rates` truncates the staging table before each load.

## Data Factory
Linked services:
- `ls_http_nbp` - NBP API
- `ls_adls` - ADLS Gen2 storage account (`stnbpdev`)
- `ls_sql` - Azure SQL database (`sqldb-nbp-dev`)

Datasets (parameterized):
- `ds_http_nbp_tables` - NBP table A for a date range (`startDate`, `endDate`)
- `ds_adls_raw_json` - JSON file in the `raw` container (`folderPath`, `fileName`)
- `ds_sql_table` - any table in the database (`schemaName`, `tableName`)

Naming: `ls_` linked service, `ds_` dataset
Dataset name = linked service name + what it points to

## Security
The factory connects to storage and SQL with its system-assigned managed identity,
so there are no keys or passwords in the repo.

- Storage: Storage Blob Data Contributor on the `raw` container only.
- SQL: no database roles, only object permissions -
  insert into the staging table and execute the two procedures.
  The factory cannot change `dbo` or `ctl` tables directly.
- Staging is truncated through a procedure with `EXECUTE AS OWNER`,
  because `TRUNCATE` needs `ALTER` on the table.

## Setup
1. Fork this repo and create the Azure resources (names are globally unique, so use your own):
   - ADLS Gen2 storage account (hierarchical namespace on) with a `raw` container
   - Azure SQL server with a Microsoft Entra admin and a database
   - Data Factory with Git integration to your fork (root folder `/adf`)
2. Update the storage URL and SQL server/database in `adf/linkedService/`
   and the factory name in `sql/08` and `tests/test_adf_permissions.sql`.
3. Add your client IP to the SQL server firewall, then run the scripts in `sql/`
   in numeric order while connected with Microsoft Entra authentication.
4. On the SQL server, enable *Allow Azure services and resources to access this server*.
5. On the `raw` container, assign Storage Blob Data Contributor to the factory's managed identity.
   (it can take a few minutes to apply).
6. In `ls_adls`, *Test connection -> To linked service* fails by design
   (no account-level access). Use *To file path* with `raw`.

## Testing
- `tests/test_usp_merge_exchange_rates.sql` - checks the merge procedure
  (dev only - it truncates the tables).
- `tests/test_adf_permissions.sql` - checks that the factory identity has only
  the permissions it needs and cannot modify target or control tables directly.

## Status
- [x] Azure resources
- [x] SQL schema and merge procedure
- [x] Linked services, datasets and permissions
- [ ] Ingestion pipeline
- [ ] Incremental load + scheduling
- [ ] Logging and error handling