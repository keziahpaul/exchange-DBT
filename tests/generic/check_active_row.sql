{% test check_active_row(model,column_name,pk_field_list ) %}
    {#  Curate Test to check if max extraction_ts in stage is the active in curate #}
    select {{ pk_field_list }}, count(*)
    from {{ model }}
    where effective_to::date =  '{{var('active_date')}}'
    group by {{ pk_field_list }}
    having COUNT(*) > 1
{% endtest %}
