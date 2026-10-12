
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_prj_batch_job_execution') %}  
 {% set pk = 'job_execution_id'%} 
 
        
{% set columns_config %}
    OP,
    EXTRACTION_START_TS::TIMESTAMP_NTZ as EXTRACTION_START_TS,
    JOB_EXECUTION_ID::NUMBER as JOB_EXECUTION_ID,
    VERSION::NUMBER as VERSION,
    JOB_INSTANCE_ID::NUMBER as JOB_INSTANCE_ID,
    CREATE_TIME::TIMESTAMP_NTZ as CREATE_TIME,
    START_TIME::TIMESTAMP_NTZ as START_TIME,
    END_TIME::TIMESTAMP_NTZ as END_TIME,
    STATUS as STATUS,
    EXIT_CODE as EXIT_CODE,
    EXIT_MESSAGE as EXIT_MESSAGE,
    LAST_UPDATED::TIMESTAMP_NTZ as LAST_UPDATED,
    JOB_CONFIGURATION_LOCATION as JOB_CONFIGURATION_LOCATION,   
    TRANSACT_SEQ::NUMBER as TRANSACT_SEQ
{% endset %}

{{ dms_precurate_stage_processing(src_view_name, pk, columns_config) }}