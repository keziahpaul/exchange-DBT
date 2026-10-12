
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_report_audit') %}  
 {% set pk = 'id'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    CREATED_AT::TIMESTAMP_NTZ as CREATED_AT,
    USERNAME as USERNAME,
    PROJECT_ID::NUMBER as PROJECT_ID,
    SUBSCRIBER_ID as SUBSCRIBER_ID,
    REPORT_TYPE as REPORT_TYPE,
    INPUT_PARAMETERS::VARIANT as INPUT_PARAMETERS,
    EXTERNAL_API::BOOLEAN as EXTERNAL_API,
    JURISDICTION as JURISDICTION,
    PROJECT_NAME as PROJECT_NAME,
    SUBSCRIBER_NAME as SUBSCRIBER_NAME,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}