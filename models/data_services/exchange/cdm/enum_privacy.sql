{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- this appears to be a random string @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, is_default
    FROM (VALUES
        ('Private', FALSE),
        ('Public', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', TRUE)
    ) v(enum_name, is_default)
)
SELECT
    '2026-03-09 18:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name
FROM enum
