{% macro dms_precurate_stage_processing(src_view_name, pk, columns_config, source_tz='UTC', target_tz='Australia/Melbourne', src_timestamp_grain='millisecond') %}

 {# Check if stage table exists and has data - low date only applies when stage is empty or missing #}
 {% set stage_relation = adapter.get_relation(
     database=this.database,
     schema=this.schema,
     identifier=this.identifier
 ) %}
 {% set use_low_date = true %}
 {% if stage_relation is not none %}
     {% set row_count_query %}
         select count(*) as cnt from {{ stage_relation }}
     {% endset %}
     {% set results = run_query(row_count_query) %}
     {% if results and results.rows[0][0] > 0 %}
         {% set use_low_date = false %}
     {% endif %}
 {% endif %}

with 
 {% if is_incremental() %}  
     latest_ts as ( 
     select max(EXTRACTION_START_TS) as last_extracted_ts from {{this}} 
     ), 
 {% endif %}
  
  base as (   
    select 
        {{columns_config}}
    from  {{ src_view_name }} 
    {% if is_incremental() %} 
    where EXTRACTION_START_TS > (select last_extracted_ts from latest_ts )
    {% endif %}  
    ),
  
 initial as( 
    select  *,
        lead(op) over (partition by {{pk}} order by transact_seq asc nulls first) as next_op, 
        case when transact_seq is null 
        then 
        {% if use_low_date %}
            '{{var('low_date')}}'::timestamp
        {%else%}
             CONVERT_TIMEZONE( '{{source_tz}}', '{{target_tz}}',
             dateadd('{{src_timestamp_grain}}',-row_number() over (
                partition by {{pk}}
                order by transact_seq desc nulls last), 
                min(trunc(EXTRACTION_START_TS,'{{src_timestamp_grain}}')) over (partition by {{pk}})
                ))
        {% endif %}
        else 
        CONVERT_TIMEZONE( '{{source_tz}}', '{{target_tz}}',
            dateadd('{{src_timestamp_grain}}',
            -row_number() over (
                partition by {{pk}}, trunc(EXTRACTION_START_TS,'{{src_timestamp_grain}}') 
                order by transact_seq desc)+1,
            extraction_start_ts)
        )
        end as modified_extraction_start_ts 
    from base

    ) 
    select 
     *, 
     row_number() over (partition by {{pk}} order by transact_seq asc nulls first) as row_num, 
     case when upper(op)='D' then TRUE else FALSE end as src_delete_idn, 
     case when upper(op)='D' 
             then modified_extraction_start_ts 
         when upper(next_op) ='D' 
             then lead(modified_extraction_start_ts) over (partition by {{pk}} order by transact_seq asc nulls first)
         else null 
     end as deleted_at,
     {{ var('inserted_at' ) }} as inserted_at 
 from  initial

{% endmacro %}