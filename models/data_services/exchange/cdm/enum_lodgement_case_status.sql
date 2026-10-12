{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/lodgement/LodgementCaseStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, note
    FROM (VALUES
        ('IN_PREPARATION', 'In Preparation', NULL),
        ('PREPARED', 'Prepared', NULL),
        ('READY', 'Ready', NULL),
        ('LODGING', 'Lodging', NULL),
        ('LODGED', 'Lodged', NULL),
        ('SETTLING_LODGING', 'Settling/Lodging', '< R2.3'),
        ('SETTLING_LODGED', 'Settling/Lodged', '< R2.3'),
        ('SETTLED_LODGED', 'Settled/Lodged', '< R2.3'),
        ('CLOSED', 'Completed', NULL),
        ('MANUALLY_LODGED', 'Manually Lodged', NULL),
        ('NOT_ACCEPTED', 'Not Accepted', NULL)
        {#- does not require a NULL row #}
    ) v(enum_name, enum_value, note)
)
SELECT
    '2026-03-09 18:30:00 +10'::timestamp_tz AS created_on,

    enum_name,
    enum_value,
    note,

    CASE WHEN enum_name NOT IN ('IN_PREPARATION', 'PREPARED', 'READY')
         THEN TRUE ELSE FALSE END AS locked,
    CASE WHEN enum_name IN ('LODGING', 'SETTLING_LODGING')
         THEN TRUE ELSE FALSE END AS lodging,
    CASE WHEN enum_name <> 'IN_PREPARATION'
         THEN TRUE ELSE FALSE END AS greater_than_in_prep,
    CASE WHEN enum_name = 'PREPARED'
    {#- seems like a bug not to include IN_PREPARATION in less_than_ready, but this is the code #}
         THEN TRUE ELSE FALSE END AS less_than_ready,
    CASE WHEN enum_name IN ('IN_PREPARATION', 'PREPARED', 'READY')
         THEN TRUE ELSE FALSE END AS active
FROM enum
