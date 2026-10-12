{% test check_record_effectiveness_overlap(model,pk_field_list ) %}
    {%set col1 = pk_field_list.split(',')[0] %}

    select  {{pk_field_list}}, effective_from,effective_to, effective_from_lead
    from (
        select  {{pk_field_list}}, effective_from, effective_to, 
        lead(effective_from) IGNORE NULLS OVER (PARTITION BY  {{pk_field_list}} ORDER BY effective_to asc) as effective_from_lead
        from {{model}}
        where {{col1}}  in ( select {{col1}} 
                            from (select  {{pk_field_list}} , count(*)
                                    from {{model}}
                                    group by  {{pk_field_list}}
                                    having count(*)>1
                                    order by count(*) desc
                                    )
                                )
        order by  {{pk_field_list}},effective_from asc
        )
    where effective_from_lead is not null
    and (trunc(effective_from,'millisecond') >  trunc(effective_to,'millisecond')
    OR datediff('millisecond', effective_to, effective_from_lead) < 0)
{% endtest %}