{% macro dms_timestamp_trunc(timestamp_col) -%}
    CONVERT_TIMEZONE('UTC', DATE_TRUNC('microsecond', {{ timestamp_col }}))
{%- endmacro %}

{% macro timestampntz_to_tz(timestamp_col, timezone) -%}
    TIMESTAMP_TZ_FROM_PARTS(YEAR({{ timestamp_col }}), MONTH({{ timestamp_col }}), DAY({{ timestamp_col }}), HOUR({{ timestamp_col }}), MINUTE({{ timestamp_col }}), SECOND({{ timestamp_col }}), DATE_PART(NANOSECOND, {{ timestamp_col }}), '{{ timezone }}')
{%- endmacro %}

{% macro dms_timestampntz_us_to_ns(timestamp_col, partition_cols, sequence_cols, timezone='UTC') -%}
    {% if timestamp_col is none or not timestamp_col is string or timestamp_col == '' -%}
        {{ exceptions.raise_compiler_error("timestamp_col cannot be none, must be a non-empty string") }}
    {% endif -%}
    {% if partition_cols is none -%}
        {{ exceptions.raise_compiler_error("partition_cols cannot be none") }}
    {% elif partition_cols is string -%}
        {% set partition_cols = [partition_cols] -%}
    {% endif -%}
    {% do partition_cols.append(timestamp_col) -%}
    {% set partition_by_string = partition_cols | join(", ") -%}

    {% set alias = '' -%}
    {% if timestamp_col.startswith('"') and '".' in timestamp_col -%}
        {% set alias = timestamp_col.split('".')[0] ~ '".' -%}
    {% elif not timestamp_col.startswith('"') and '.' in timestamp_col -%}
        {% set alias = timestamp_col.split('.')[0] ~ '.' -%}
    {% endif -%}
    {% set transact_seq_col = alias ~ 'transact_seq NULLS FIRST' -%}
    {% if sequence_cols is none -%}
        {% set sequence_cols = [] -%}
    {% elif sequence_cols is string -%}
        {% set sequence_cols = [sequence_cols] -%}
    {% endif -%}
    {% do sequence_cols.append(transact_seq_col) -%}
    {% set sequence_by_string = sequence_cols | join(", ") -%}

    {% set dbt_local = '_dbt_' + (timestamp_col | replace('"', '') | replace('.', '_')) -%}

DATEADD(NANOSECOND, (ROW_NUMBER() OVER (PARTITION BY {{ partition_by_string }} ORDER BY {{ sequence_by_string }}) - 1), {{ timestamp_col }}) AS {{ dbt_local }},
{%- if timezone != 'UTC' -%}
CONVERT_TIMEZONE('{{ timezone }}',
{%- endif -%}
{{ timestampntz_to_tz(dbt_local, 'UTC') }}
{%- if timezone != 'UTC' -%}
)
{%- endif %}

{%- endmacro %}
