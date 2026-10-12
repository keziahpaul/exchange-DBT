{% macro full_load_recovery(tables, recovery_date) %}
{#
    Macro: full_load_recovery
    Description: Identifies records that were active in curate before a full load date
                 but are missing from the latest full load in stage. Updates those records
                 in curate by setting effective_to to 1 millisecond before the min
                 extraction_start_ts of the full load for that table.

    Args:
        tables (list): List of table names (e.g., ['pxa_settlement_schedules', 'pxa_accounts'])
        recovery_date (string): The date of the full load used to compare against inserted_at (format: 'YYYY-MM-DD')

    Usage:
        dbt run-operation full_load_recovery --args '{tables: ["pxa_settlement_schedules", "pxa_accounts"], recovery_date: "2026-07-07"}'
#}

{% set curate_db = env_var('DBT_EXCHANGE_CURATE_DB') %}
{% set stage_db = env_var('DBT_EXCHANGE_STAGE_DB') %}
{% set schema = 'exchange' %}
{% set primary_keys_dict = var('primary_keys_dict') %}

{% for table_name in tables %}

    {% set pk_string = primary_keys_dict[table_name] %}
{% set pk_columns = [] %}
    {% for pk in pk_string.split(',') %}
        {% do pk_columns.append(pk | trim) %}
    {% endfor %}
    {% set stg_table_name = 'stg_' ~ table_name %}

    {% set pk_select = pk_columns | join(', ') %}
    {% set pk_join_condition = [] %}
    {% for pk in pk_columns %}
        {% do pk_join_condition.append('curate.' ~ pk ~ ' = missing.' ~ pk) %}
    {% endfor %}

    {{ log("Processing table: " ~ table_name, info=True) }}
    {{ log("Primary keys: " ~ pk_select, info=True) }}

    {# Step 1: Get the min extraction_start_ts from the full load in curate #}
    {% set min_extraction_ts_query %}
        select min(extraction_start_ts)
        from {{ stage_db }}.{{ schema }}.{{ stg_table_name }}
        where inserted_at::date >= '{{ recovery_date }}'
    {% endset %}

    {% set min_extraction_ts_result = run_query(min_extraction_ts_query) %}
    {% set min_extraction_ts = min_extraction_ts_result.columns[0].values()[0] %}

    {{ log("Min extraction_start_ts for " ~ table_name ~ ": " ~ min_extraction_ts, info=True) }}

    {% if min_extraction_ts is not none %}

        {# Step 2: Find missing records and update effective_to to 1ms before min extraction_start_ts #}
        {% set update_query %}
            update {{ curate_db }}.{{ schema }}.{{ table_name }} as curate
            set curate.effective_to = dateadd(millisecond, -1, '{{ min_extraction_ts }}'::timestamp_ntz)
            where curate.effective_to = '9999-12-31'::timestamp_ntz
              and curate.inserted_at < '{{ recovery_date }}'
              and exists (
                  select 1
                  from (
                      select distinct {{ pk_select }}
                      from {{ curate_db }}.{{ schema }}.{{ table_name }}
                      where effective_to = '9999-12-31'::timestamp_ntz
                        and inserted_at < '{{ recovery_date }}'
                      minus
                      select distinct {{ pk_select }}
                      from {{ stage_db }}.{{ schema }}.{{ stg_table_name }}
                      where inserted_at::date >= '{{ recovery_date }}'
                  ) as missing
                  where {{ pk_join_condition | join(' and ') }}
              )
        {% endset %}

        {{ log("Executing update for " ~ table_name ~ "...", info=True) }}
        {% do run_query(update_query) %}
        {{ log("Update complete for " ~ table_name, info=True) }}

    {% else %}
        {{ log("WARNING: No records found for date " ~ recovery_date ~ " in " ~ table_name ~ ". Skipping.", info=True) }}
    {% endif %}

    {{ log("---", info=True) }}

{% endfor %}

{{ log("Full load recovery complete.", info=True) }}

{% endmacro %}
