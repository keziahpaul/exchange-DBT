{% test check_latest_extraction_ts_active(model,pk_field_list,source ) %}
    {#  Curate Test to check if max extraction_ts in stage is the active in curate #}
    select a.pkfields,stg_version,b.pkfields,curate_version
    from(
    select concat({{pk_field_list}}) as pkfields,max(extraction_start_ts) as stg_version
    from {{source}}
    where OP<>'D'
    group by concat({{pk_field_list}}) ) a
    full join
    (select concat({{pk_field_list}}) as pkfields, extraction_start_ts as curate_version
    from {{model}}
    where effective_to ='9999-12-31 00:00:00.000'
    )b
    on a.pkfields=b.pkfields
    where stg_version<>curate_version
{% endtest %}