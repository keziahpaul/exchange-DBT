
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_api_usage_audit') %}  
 {% set pk = 'id'%} 
 
{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    ENDPOINT_NAME,
    PROJECT_ID,
    PROJECT_NAME,
    PEXA_CORE_WORKSPACE_ID,
    OAUTH_GRANT_TYPE,
    INTEGRATOR,
    INTEGRATOR_TYPE,
    AUTHORISED_PARTY,
    SUBSCRIBER_ID,
    EMAIL,
    CREATED_AT::TIMESTAMP_NTZ as CREATED_AT,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}
    