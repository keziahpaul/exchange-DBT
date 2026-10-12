{% test check_update_before_inserts(model,pk_field_list ) %}
    {# Stage Test to check if there are updates before inserts #}
    select {{pk_field_list}}, op, extraction_start_ts from (
    select op , {{pk_field_list}}, extraction_start_ts, row_number() over (partition by {{pk_field_list}} order by extraction_start_ts asc) as rn
    from {{model}}
    order by {{pk_field_list}}, extraction_start_ts)
    where rn=1 and OP='U'
{% endtest %}