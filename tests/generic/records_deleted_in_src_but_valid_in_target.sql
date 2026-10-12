{% test records_deleted_in_src_but_valid_in_target(model,pk_field_list=None,source=None) %}
     
    {%if pk_field_list==None and source==None%}
    {%set key = model.name|replace('stg_','')%}
    {%set pk_field_list = var('primary_keys_dict')[key]%}
    {%set source = model|replace('pxa_','stg_pxa_')|replace('CURATE','STAGE')%}
    {%endif%}

    WITH deleted_records as 
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
    AND op IN ('D')
    )

    select {{pk_field_list}}
    from {{model}}
    where   concat({{pk_field_list}}) in   (select id from deleted_records )
    and effective_to='9999-12-31 00:00:00.000'

{% endtest %}

    