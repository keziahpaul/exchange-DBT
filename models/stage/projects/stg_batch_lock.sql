
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_batch_lock') %}  
 {% set pk = 'id'%} 
 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    PROJECT_ID::NUMBER as PROJECT_ID,
    concat(CREATED_AT, '+0000')::timestamp_tz as CREATED_AT,
    MOT_PROJECT_ID::NUMBER as MOT_PROJECT_ID,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}