{{
  config(
    materialized = 'from_external_stage',
    stage_name = env_var('DBT_EXCHANGE_RAW_DB') + "." + env_var('DBT_PEXAKEY_RAW_SCHEMA') + ".PEXAKEY_S3_INBOUND_STAGE/ms-api-property-settlement-ms-"+env_var('DBT_ENV_NAME')+env_var('DBT_PEXAKEY_S3_KEY_PATH'),
    stage_file_format = 'JSON',
    schema_name = env_var('DBT_PEXAKEY_RAW_SCHEMA')
    )
}}

SELECT
$1::variant as data
FROM {{ pexa_one_data_au_dbt_common_lib.external_stage() }}