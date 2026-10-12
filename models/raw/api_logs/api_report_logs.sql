{{
  config(
    materialized = 'from_external_stage',
    stage_name = env_var('DBT_EXCHANGE_RAW_DB') + "." + env_var('DBT_API_LOGS_RAW_SCHEMA') + ".API_LOGS_S3_INBOUND_REPORT_STAGE",
    stage_file_format = 'JSON',
    schema_name = env_var('DBT_API_LOGS_RAW_SCHEMA'),
    file_pattern=env_var('DBT_API_S3_KEY_PATH_PATTERN')
    )
}}

SELECT
$1::variant as data
FROM {{ pexa_one_data_au_dbt_common_lib.external_stage() }}