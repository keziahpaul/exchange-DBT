{#-- macros/materializations/stored_procedure.sql --#}
{% materialization stored_proc_test, adapter='snowflake' %}

  {% set target = api.Relation.create(
      database=this.database, schema=this.schema, identifier=this.identifier, type='table'
  ) %}
  

  {% set sproc_name = config.get('procedure_name') or var('procedure_name') %}
  {% if not sproc_name %}
    {{ exceptions.raise_compiler_error("Set snowflake_procedure` in config/vars for 'sproc' materialization.") }}
  {% endif %}

  {% if should_full_refresh() %}
    {{ adapter.drop_relation(target) }}
  {% endif %}

  {{ run_hooks(pre_hooks, inside_transaction=True) }}
  
  {% call statement('main') %}

    call {{ sproc_name }}(
      {{ model.config.get('procedure_args', '') }} )

  {% endcall %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {{ return({'relations': [target]}) }}

{% endmaterialization %}
