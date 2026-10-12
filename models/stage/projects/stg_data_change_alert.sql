
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_data_change_alert') %}  
{% set pk = 'id'%} 
 
{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    WORKSPACE_ID::NUMBER as WORKSPACE_ID,
    SUBSCRIBER_REFERENCE as SUBSCRIBER_REFERENCE,
    concat(CREATED_AT, '+0000')::timestamp_tz as CREATED_AT,
    concat(UPDATED_AT, '+0000')::timestamp_tz as src_updated_at,
    ALERT_READ::BOOLEAN as ALERT_READ,
    ALERT_FLAGGED::BOOLEAN as ALERT_FLAGGED,
    CHANGE_TYPE as CHANGE_TYPE,
    CHANGE_FROM as CHANGE_FROM,
    CHANGE_TO as CHANGE_TO,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}