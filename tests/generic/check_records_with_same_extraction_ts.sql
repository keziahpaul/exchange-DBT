{% test check_records_with_same_extraction_ts(model,pk_field_list ) %}
    {# Stage Test to check if there are multiple records for same primary key with same extraction_start_ts #}
    select  {{pk_field_list}}, extraction_start_ts, count(*)
    from  {{model}}
    group by {{pk_field_list}},extraction_start_ts
    having count(*)>1

{% endtest %}