
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
{% set src_view_name= ref('vw_prj_configuration') %}  
{% set pk = 'id'%} 
 
{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    ID::NUMBER as ID,
    NAME as NAME,
    DATA::VARIANT as DATA,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}