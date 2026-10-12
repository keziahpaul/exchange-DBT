{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}

SELECT
    id,
    inserted_at AS event_ts,
    subscriber_name,
    subscriber_type,
    subscriber_category,
    subscriber_reference,
    workgroup,
    party_represented,
    dual_signing_settlement,
    dual_signing_document,
    participant_status,
    dual_authorisation,
    pexa_project_id,
    pexa_project_name,
    acceptance_status,
    accepted_by,
    settle_acceptance_status,
    user_id,
    settle_accepted_date,
    settle_accept_by_username,
    settle_accept_by_subscriber_id,
    settle_accept_by_system_user,
    withdraw_reason,
    withdraw_info
FROM {{ref('stg_cdm_participant_event')}}
{%- if is_incremental() %}
WHERE inserted_at > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(event_ts)') }} FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY event_ts
