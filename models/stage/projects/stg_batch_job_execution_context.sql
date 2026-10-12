
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_batch_job_execution_context') %}  
 {% set pk = 'job_execution_id'%} 
 
 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    JOB_EXECUTION_ID::NUMBER as JOB_EXECUTION_ID,
    SHORT_CONTEXT as SHORT_CONTEXT,
    SERIALIZED_CONTEXT as SERIALIZED_CONTEXT,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}