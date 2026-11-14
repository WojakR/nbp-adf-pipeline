-- Initial watermark for NBP table A.
-- Incremental loads start from last_loaded_date + 1 day.

IF NOT EXISTS (
    SELECT 1 FROM ctl.watermark WHERE source_name = 'nbp_table_a'
)
INSERT INTO ctl.watermark (source_name, last_loaded_date)
VALUES ('nbp_table_a', '2025-12-31')