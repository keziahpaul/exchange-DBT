{% set source_name= source('PROJECTS_S3', 'batch_report_item') %}  
 {% set base_column_list= dbt_utils.star(from= source_name, except =['VALUE','PARTITION_NAME']) %} 
     select METADATA$FILENAME as metadata_filename,
     {{ base_column_list }}
     from {{ source_name }}