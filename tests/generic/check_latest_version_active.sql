{% test check_latest_version_active(model,pk_field_list,source,version_col ) %}
    {#  Curate Test to check if max version in stage is the active version in curate #}
    select a.pkfields,stg_version,b.pkfields,curate_version
    from(
    select concat({{pk_field_list}}) as pkfields,max({{version_col}}) as stg_version
    from {{source}}
    group by concat({{pk_field_list}}) ) a
    full join
    (select concat({{pk_field_list}}) as pkfields, {{version_col}} as curate_version
    from {{model}}
    where effective_to ='9999-12-31 00:00:00.000'
    )b
    on a.pkfields=b.pkfields
    where stg_version<>curate_version
{% endtest %}