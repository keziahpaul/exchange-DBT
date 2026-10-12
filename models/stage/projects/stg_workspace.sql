
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_workspace') %}  
 {% set pk = 'id'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    PROJECT_ID::NUMBER as PROJECT_ID,
    DATA::VARIANT as DATA,
    MODIFIED_BY_IP::VARIANT as MODIFIED_BY_IP,
    VERSION::NUMBER as VERSION,
    CREATED_ON::TIMESTAMP_NTZ as CREATED_ON,
    CREATED_BY as CREATED_BY,
    LAST_MODIFIED_ON::TIMESTAMP_NTZ as LAST_MODIFIED_ON,
    LAST_MODIFIED_BY as LAST_MODIFIED_BY,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}