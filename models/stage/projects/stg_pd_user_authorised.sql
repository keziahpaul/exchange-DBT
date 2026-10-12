
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_pd_user_authorised') %}  
 {% set pk = 'id'%}  

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    SUBSCRIBER_ID as SUBSCRIBER_ID,
    POT::BOOLEAN as POT,
    MOT::BOOLEAN as MOT,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}