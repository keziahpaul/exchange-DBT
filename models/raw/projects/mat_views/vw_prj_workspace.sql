{% set source_name= source('PROJECTS_S3', 'workspace') %}  
 {% set base_column_list= dbt_utils.star(from= source_name, except =['VALUE','PARTITION_NAME']) %} 
     select METADATA$FILENAME as metadata_filename,
     {{ base_column_list }}
     from {{ source_name }}