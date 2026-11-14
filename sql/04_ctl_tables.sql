-- Control tables: load state (watermark) and pipeline run log.

-- Last successfully loaded date per source.
IF OBJECT_ID('ctl.watermark') IS NULL
CREATE TABLE ctl.watermark (
    source_name       VARCHAR(50)   NOT NULL,
    last_loaded_date  DATE          NOT NULL,
    updated_at        DATETIME2(0)  NOT NULL
        CONSTRAINT DF_watermark_loaded_at DEFAULT SYSUTCDATETIME(),
    
    CONSTRAINT PK_watermark PRIMARY KEY (source_name)
);

-- One row per ADF pipeline run: inserted at start, updated at the end.
IF OBJECT_ID('ctl.pipeline_runs') IS NULL
CREATE TABLE ctl.pipeline_runs (
    run_id             UNIQUEIDENTIFIER  NOT NULL,
    pipeline_name      VARCHAR(100)      NOT NULL,
    source_name        VARCHAR(50)       NOT NULL,
    run_status         VARCHAR(20)       NOT NULL,
    rows_copied        INT               NULL,
    started_at         DATETIME2(0)      NOT NULL
        CONSTRAINT DF_pipeline_runs_started_at DEFAULT SYSUTCDATETIME(),
    finished_at        DATETIME2(0)      NULL,
    error_messages     NVARCHAR(MAX)     NULL,

    CONSTRAINT PK_pipeline_runs PRIMARY KEY (run_id),
    CONSTRAINT CK_pipeline_runs_run_status
        CHECK (run_status IN ('InProgress', 'Succeeded', 'Failed', 'NoData'))
);