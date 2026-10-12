{% test check_inserts_deletes_at_same_time(model,pk_field_list ) %}
    {#  Stage Test to check if there are inserts anbd deletes at same timestamp #}
    select distinct concat({{pk_field_list}}) as pk   
    from {{model}}
    where OP in ('I','D')
    and concat({{pk_field_list}}) in (
        select concat({{pk_field_list}}) as pk  
        from {{model}}
        where OP in ('I','D')
        group by {{pk_field_list}}
        having count(*)>2)
    group by concat({{pk_field_list}}),extraction_start_ts
    having count(*)>1
{% endtest %}