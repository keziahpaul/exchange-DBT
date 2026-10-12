
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_financial_accounts_audit') %}  
 {% set pk = 'id'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    POT_PROJECT_ID::NUMBER as POT_PROJECT_ID,
    MOT_PROJECT_ID::NUMBER as MOT_PROJECT_ID,
    USER_ID::NUMBER as USER_ID,
    concat(ACTION_DATE, '+0000')::timestamp_tz as ACTION_DATE,
    ACTION as ACTION,
    BEFORE_DESCRIPTION as BEFORE_DESCRIPTION,
    AFTER_DESCRIPTION as AFTER_DESCRIPTION,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}