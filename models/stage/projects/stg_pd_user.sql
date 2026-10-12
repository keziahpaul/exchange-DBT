
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_pd_user') %}  
 {% set pk = 'id'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    EMAIL as EMAIL,
    SUBSCRIBER_ID as SUBSCRIBER_ID,
    FIRST_NAME as FIRST_NAME,
    LAST_NAME as LAST_NAME,
    SUBSCRIBER_NAME as SUBSCRIBER_NAME,
    TYPE as TYPE,
    WORKGROUPS::VARIANT as WORKGROUPS,
    SUBSCRIBER_DUAL_SIGN_FSS::BOOLEAN as SUBSCRIBER_DUAL_SIGN_FSS,
    SUBSCRIBER_DUAL_SIGN_DOC::BOOLEAN as SUBSCRIBER_DUAL_SIGN_DOC,
    USER_PERMISSIONS::VARIANT as USER_PERMISSIONS,
    CREATED_ON::TIMESTAMP_NTZ as CREATED_ON,
    CREATED_BY as CREATED_BY,
    LAST_MODIFIED_ON::TIMESTAMP_NTZ as LAST_MODIFIED_ON,
    LAST_MODIFIED_BY as LAST_MODIFIED_BY,
    VERSION::NUMBER as VERSION,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}