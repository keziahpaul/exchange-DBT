{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/subscriber/SubscriberStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value
    FROM (VALUES
        ('ACTIVE', 'Active'),
        ('SUSPENDED', 'Suspended'),
        ('TERMINATED', 'Terminated'),
        ('PENDING', 'Pending'),
        ('RESTRICTED', 'Restricted')
        {#- does not require a NULL row #}
    ) v(enum_name, enum_value)
)
SELECT
    '2026-03-12 12:30:00 +10'::timestamp_tz AS created_on,

    enum_name,
    enum_value,
    
    CASE WHEN enum_name IN ('TERMINATED', 'SUSPENDED', 'RESTRICTED')
         THEN TRUE ELSE FALSE END AS is_inactive,
    CASE WHEN enum_name IN ('TERMINATED', 'SUSPENDED')
         THEN TRUE ELSE FALSE END AS is_terminated,
    CASE WHEN enum_name = 'ACTIVE'
         THEN TRUE ELSE FALSE END AS is_active
FROM enum