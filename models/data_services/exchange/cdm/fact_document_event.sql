{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['id', 'event_ts']
    )
}}

WITH lodge_doc_src AS (
    SELECT
        l.id,
        l.date_changed AS event_ts,
        {#- lodgement_date,     -- need via fact_lodgement_event.lodgement_date #}
        l.status,
        l.settlement_id,
        l.order_of_lodgement,
        l.is_delete,
        COALESCE(e.enum_value, 'UNKNOWN') AS status_description,
        e.is_active,
        e.is_submitted,
        e.is_nsw_completed,
        e.is_qld_completed,
        e.is_tas_completed,
        e.is_vic_completed,
        e.is_wa_completed
    FROM {{ ref('stg_cdm_lodgement_document_event') }} l
    LEFT JOIN {{ ref('enum_document_status') }} e ON l.status = e.enum_name
    {%- if is_incremental() %}
    WHERE l.date_changed > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(event_ts)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
)
SELECT
    id,
    event_ts,
    status,
    settlement_id,
    order_of_lodgement,
    is_delete,
    status_description,
    is_active,
    is_submitted,
    is_nsw_completed,
    is_qld_completed,
    is_tas_completed,
    is_vic_completed,
    is_wa_completed
FROM lodge_doc_src
ORDER BY event_ts
