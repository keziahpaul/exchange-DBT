
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_subscriber_to_tnc') %}  
 {% set pk = 'id'%} 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    TNC_VERSION::NUMBER as TNC_VERSION,
    SUBSCRIBER_ID as SUBSCRIBER_ID,
    FOR_POT::BOOLEAN as FOR_POT,
    FOR_MOT::BOOLEAN as FOR_MOT,
    ACCEPTED_ON::TIMESTAMP_NTZ as ACCEPTED_ON,
    DEFAULT_LOGIN_AS_POT::BOOLEAN as DEFAULT_LOGIN_AS_POT,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}