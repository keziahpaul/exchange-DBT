
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_batch_job_instance') %}  
 {% set pk = 'job_instance_id'%} 
 

{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    JOB_INSTANCE_ID::NUMBER as JOB_INSTANCE_ID,
    VERSION::NUMBER as VERSION,
    JOB_NAME as JOB_NAME,
    JOB_KEY as JOB_KEY,
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}