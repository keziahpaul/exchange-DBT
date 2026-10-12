{% set source_name= source('EXCHANGE_S3', 'pxa_subscriber_types') %}  
 {% set base_column_list= dbt_utils.star(from= source_name, except =['VALUE','PARTITION_NAME']) %} 
     select METADATA$FILENAME as metadata_filename,
     {{ base_column_list }}
     from {{ source_name }}