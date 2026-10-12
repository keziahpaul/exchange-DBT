
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('vw_pxa_fee_discounts') %}  
 {% set base_column_list= dbt_utils.star(from= src_view_name, except =['METADATA_FILENAME']) %} 

 

 {% if is_incremental() %}  
     with latest_ts as ( 
     select max(EXTRACTION_START_TS) as last_extracted_ts from {{this}} 
     )
 {% endif %}
  
 
    select  
        {{ base_column_list }}, 
        {{ var('inserted_at' ) }} as inserted_at 
    from  {{ src_view_name }} 
 {% if is_incremental() %} 
     where EXTRACTION_START_TS > (select last_extracted_ts from latest_ts )
 {% endif %} 