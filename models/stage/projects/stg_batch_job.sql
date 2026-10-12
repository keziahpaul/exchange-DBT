
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_batch_job') %}  
 {% set pk = 'id'%} 
 
{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    PROJECT_ID::NUMBER as PROJECT_ID,
    USER_ID::NUMBER as USER_ID,
    concat(CREATED_AT, '+0000')::timestamp_tz as CREATED_AT,
    concat(UPDATED_AT, '+0000')::timestamp_tz as src_updated_at,
    STATUS,
    FILE_NAME,
    TYPE,
    ROLE,
    concat(SETTLEMENT_DATE_TIME, '+0000')::timestamp_tz as SETTLEMENT_DATE_TIME,
    FAILED_ITEMS::NUMBER as FAILED_ITEMS,
    TOTAL_ITEMS::NUMBER as TOTAL_ITEMS,
    MOT_PROJECT_ID::NUMBER as MOT_PROJECT_ID,
    CREATED_ON::TIMESTAMP_NTZ as CREATED_ON,
    CREATED_BY,
    LAST_MODIFIED_ON::TIMESTAMP_NTZ as LAST_MODIFIED_ON,
    LAST_MODIFIED_BY,
    VERSION::NUMBER as VERSION,
    TOKEN,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}
    