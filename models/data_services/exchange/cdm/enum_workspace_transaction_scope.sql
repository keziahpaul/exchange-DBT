{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/workspace/WorkspaceTransactionScope.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, is_default
    FROM (VALUES
        ('SALES_OR_PURCHASE', 'Sales or purchase', FALSE),
        ('OTHER', 'Other', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 'Unknown Workspace Transaction Scope', TRUE)
    ) v(enum_name, enum_value, is_default)
)
SELECT
    '2026-03-10 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value
FROM enum
