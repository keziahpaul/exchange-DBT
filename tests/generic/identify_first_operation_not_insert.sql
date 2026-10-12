{% test identify_first_operation_not_insert(model,pk_field_list=none) %}

    {%if pk_field_list==None%}
    {%set key = model.name|replace('stg_','')%}
    {%set pk_field_list = var('primary_keys_dict')[key]%}
    {%endif%}

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
            transact_seq  asc nulls first
        ) AS rn
        FROM
        {{model}}
    ) AS subquery
    WHERE
    rn = 1
    AND op NOT IN ('I')


{% endtest %}