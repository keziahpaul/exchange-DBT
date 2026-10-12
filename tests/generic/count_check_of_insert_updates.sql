{% test count_check_of_insert_updates(model,pk_field_list=None,source=None) %}
     
    {%if pk_field_list==None and source==None%}
    {%set key = model.name|replace('stg_','')%}
    {%set pk_field_list = var('primary_keys_dict')[key]%}
    {%set source = model|replace('pxa_','stg_pxa_')|replace('CURATE','STAGE')%}
    {%endif%}

    WITH valid_records as 
    (
     SELECT
    id,
    FROM
    (
        SELECT
        concat({{pk_field_list}}) as id,
        op,
        ROW_NUMBER() OVER (
            PARTITION BY  {{pk_field_list}}
            ORDER BY
            modified_extraction_start_ts desc
        ) AS rn
        FROM
        {{source}}
    ) AS subquery
    WHERE
    rn = 1
    AND op IN ('I', 'U')
    )

    select stg_cnt,curate_cnt, (stg_cnt-curate_cnt) as diff 
    from 
        (select 'valid_count' as c1 , count(*) as stg_cnt 
        from valid_records) v
        join 
        (select 'valid_count' as c1 , count(*) as curate_cnt 
        from {{model}}
        where  effective_to='9999-12-31 00:00:00.000') a
    on v.c1=a.c1
    where diff !=0
{% endtest %}


