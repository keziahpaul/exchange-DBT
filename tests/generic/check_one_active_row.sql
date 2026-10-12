{% test check_one_active_row(model,pk_field_list=None) %}
    {%if pk_field_list==None%}
    {%set key = model.name|replace('vw_','pxa_')%}
    {%set pk_field_list = var('primary_keys_dict')[key]%}
    {%endif%}

    SELECT  {{pk_field_list}}, count(*)
    FROM {{ model }}
    WHERE effective_to::date =  '{{var('active_date')}}'
    GROUP BY {{pk_field_list}}
    HAVING COUNT(*) > 1
{% endtest %}