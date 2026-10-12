{% macro stage_recovery(tables, recovery_date) %}
{#
    Macro: stage_recovery
    Description: Identifies records in stage tables that existed before a full load date
                 but are missing from the latest full load (indicating they were deleted at source).
                 Inserts synthetic delete records (op='D') into the stage table with only the
                 primary key and metadata columns populated.

    Args:
        tables (list): List of table names without stg_ prefix (e.g., ['pxa_settlement_schedules', 'pxa_accounts'])
        recovery_date (string): The date of the full load used to compare against inserted_at (format: 'YYYY-MM-DD')

    Usage:
        dbt run-operation stage_recovery --args '{tables: ["pxa_settlement_schedules", "pxa_accounts"], recovery_date: "2026-07-07"}'
#}

{% set stage_db = env_var('DBT_EXCHANGE_STAGE_DB') %}
{% set schema = env_var('DBT_EXCHANGE_STAGE_SCHEMA') %}
{% set recovery_date = recovery_date ~ ' 00:00:00 +1000' %}
{% set primary_keys_dict = var('primary_keys_dict') %}

{% for table_name in tables %}
    {% set table_name = table_name | trim | lower %}
    {% set pk_string = primary_keys_dict[table_name] %}
    {% set stg_table_name = 'stg_' ~ table_name %}

    {{ log("Processing table: " ~ stg_table_name, info=True) }}
    {{ log("Primary keys: " ~ pk_string, info=True) }}

    {# Step 1: Get all columns from the stage table #}
    {% set columns_query %}
        select column_name
        from {{ stage_db }}.information_schema.columns
        where table_schema = upper('{{ schema }}')
          and table_name = upper('{{ stg_table_name }}')
        order by ordinal_position
    {% endset %}

    {% set columns_result = run_query(columns_query) %}

    {{ log("Found " ~ columns_result.columns[0].values() | length ~ " columns in " ~ stg_table_name, info=True) }}

    {# Step 2: Build insert columns and select expressions - only metadata fields needed for the D record #}
    {% set ins_cols = [pk_string] %}
    {% set col_ops = [pk_string] %}

    {% for col_name in columns_result.columns[0].values() %}
        {% if col_name == 'OP' %}
            {% do ins_cols.append(col_name) %}
            {% do col_ops.append("'D' AS " ~ col_name) %}
        {% elif col_name in ['EXTRACTION_START_TS', 'MODIFIED_EXTRACTION_START_TS', 'DELETED_AT'] %}
            {% do ins_cols.append(col_name) %}
            {% do col_ops.append("restart_ntz AS " ~ col_name) %}
        {% elif col_name == 'TRANSACT_SEQ' %}
            {% do ins_cols.append(col_name) %}
            {% do col_ops.append("(TO_VARCHAR(restart_ntz, 'yyyyMMddHH24missff2') || '0000000000000000000')::NUMBER(38,0) AS " ~ col_name) %}
        {% elif col_name == 'ROW_NUM' %}
            {% do ins_cols.append(col_name) %}
            {% do col_ops.append("1 AS " ~ col_name) %}
        {% elif col_name == 'SRC_DELETE_IDN' %}
            {% do ins_cols.append(col_name) %}
            {% do col_ops.append("TRUE AS " ~ col_name) %}
        {% elif col_name == 'INSERTED_AT' %}
            {% do ins_cols.append(col_name) %}
            {% do col_ops.append("restart_tz AS " ~ col_name) %}
        {% endif %}
    {% endfor %}

    {% set ins_cols_str = ins_cols | join(', ') %}
    {% set col_ops_str = col_ops | join(', ') %}

    {# Step 3: Insert synthetic delete records #}
    {% set insert_query %}
        insert into {{ stage_db }}.{{ schema }}.{{ stg_table_name }} ({{ ins_cols_str }})
        with first_restart as (
            select
                min(EXTRACTION_START_TS) - interval '1 millisecond' as restart_ntz,
                CONVERT_TIMEZONE('Australia/Sydney', TIMESTAMP_TZ_FROM_PARTS(YEAR(restart_ntz), MONTH(restart_ntz), DAY(restart_ntz), HOUR(restart_ntz), MINUTE(restart_ntz), SECOND(restart_ntz), DATE_PART(NANOSECOND, restart_ntz), 'UTC')) as restart_tz
            from {{ stage_db }}.{{ schema }}.{{ stg_table_name }}
            where inserted_at >= '{{ recovery_date }}'
        ),
        missing_deletes as (
            -- get pk that weren't deleted
            select distinct {{ pk_string }}
            from {{ stage_db }}.{{ schema }}.{{ stg_table_name }}
            where inserted_at < '{{ recovery_date }}'
            qualify 'D' != first_value(op) over (partition by {{ pk_string }} order by EXTRACTION_START_TS desc, TRANSACT_SEQ desc nulls last)
            minus
            -- ignore pk that were exported since
            select distinct {{ pk_string }}
            from {{ stage_db }}.{{ schema }}.{{ stg_table_name }}
            where inserted_at >= '{{ recovery_date }}' -- add condition for transact_seq is null
        )
        select {{ col_ops_str }}
        from missing_deletes, first_restart
    {% endset %}

    {{ log("Inserting synthetic delete records for " ~ stg_table_name ~ "...", info=True) }}
    {% do run_query(insert_query) %}
    {{ log("Insert complete for " ~ stg_table_name, info=True) }}

    {{ log("---", info=True) }}

{% endfor %}

{{ log("Stage recovery complete.", info=True) }}

{% endmacro %}
