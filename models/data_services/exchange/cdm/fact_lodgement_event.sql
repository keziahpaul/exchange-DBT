{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['id', 'event_ts']
    )
}}

WITH lodge_event_src AS (
    SELECT
        l.id,
        l.date_changed AS event_ts,
        l.settlement_id,
        l.status,
        l.lodgement_date,
        l.is_delete,
        e.enum_value AS label,
        e.note,
        e.locked,
        e.lodging,
        e.greater_than_in_prep,
        e.less_than_ready,
        e.active
    FROM {{ref('stg_cdm_lodgement_event')}} l
    JOIN {{ref('enum_lodgement_case_status')}} e ON l.status = e.enum_name
    {%- if is_incremental() %}
    WHERE l.date_changed > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(event_ts)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
)
SELECT
    id,
    event_ts,
    settlement_id,
    status,
    lodgement_date,
    is_delete,
    label,
    note,
    locked,
    lodging,
    greater_than_in_prep,
    less_than_ready,
    active
FROM lodge_event_src
ORDER BY event_ts
