{% test confirm_deleted_records(model,pk_field_list,source ) %}
    {# Curate test to identify records which are deleted in stage but active in curate #}
    select * from {{ model }}
    where concat({{pk_field_list}}) in (
    select concat({{pk_field_list}}) from {{source}}
    where OP ='D') 
    and effective_to ='9999-12-31 00:00:00.000'
{% endtest %}