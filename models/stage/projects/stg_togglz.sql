
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_togglz') %}  
 {% set pk = 'feature_name'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    FEATURE_NAME as FEATURE_NAME,
    FEATURE_ENABLED::NUMBER as FEATURE_ENABLED,
    STRATEGY_ID as STRATEGY_ID,
    STRATEGY_PARAMS as STRATEGY_PARAMS,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}