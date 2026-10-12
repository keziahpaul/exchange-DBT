{{ 
    config
    (
    materialized='stored_proc',
    procedure_name=env_var('DBT_EXCHANGE_RAW_DB') + '.' + env_var('DBT_PEXAKEY_RAW_SCHEMA') +'.LOAD_RDS_TO_RAW',
    procedure_args="'tracking','incremental','public','"+env_var('DBT_EXCHANGE_RAW_DB') +"','"+ env_var('DBT_PEXAKEY_RAW_SCHEMA') +"','record_updated'"
    ) 
}}

-- No SQL SELECT statement is needed here, as the stored procedure handles the logic
-- You can add a dummy SELECT 1 as a placeholder if dbt requires content,
-- but the core logic is in the stored procedure.
SELECT 1 AS dummy_column