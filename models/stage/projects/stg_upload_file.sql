
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_upload_file') %}  
 {% set pk = 'id'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    POT_PROJECT_ID::NUMBER as POT_PROJECT_ID,
    MOT_PROJECT_ID::NUMBER as MOT_PROJECT_ID,
    STATUS as STATUS,
    FILE_TYPE as FILE_TYPE,
    FILE_CONTENT::VARIANT as FILE_CONTENT,
    MAPPED_CONTENT::VARIANT as MAPPED_CONTENT,
    USER_ID::NUMBER as USER_ID,
    concat(CREATED_AT, '+0000')::timestamp_tz as CREATED_AT,
    concat(UPDATED_AT, '+0000')::timestamp_tz as src_updated_at,
    CREATED_ON::TIMESTAMP_NTZ as CREATED_ON,
    CREATED_BY as CREATED_BY,
    LAST_MODIFIED_ON::TIMESTAMP_NTZ as LAST_MODIFIED_ON,
    LAST_MODIFIED_BY as LAST_MODIFIED_BY,
    VERSION::NUMBER as VERSION,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}