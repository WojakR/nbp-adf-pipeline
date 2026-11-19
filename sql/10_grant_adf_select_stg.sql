-- ADF Copy sink uses SqlBulkCopy, which reads destination table metadata and requires SELECT.
GRANT SELECT ON OBJECT::stg.exchange_rates TO [adf-nbp-dev];