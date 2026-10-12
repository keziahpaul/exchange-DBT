{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'event_ts']
    )
}}

SELECT
    id,
    date_changed AS event_ts,
    deleted,
    property_detail_id,
    updated_address_display,
    initial_ris_date,
    lot_in_unregistered_plan,
    ltrv_warning_code,

    address,
    estate_type,
    issued,
    description,
    bundle_subscription,
    duplicate_ct_issued,
    cert_of_title_details_id,
    positive_tac_flag,
    tac_failure_flag,
    prop_details_address_id,
    title_type,
    sub_jurisdiction,
    numerator_share_of_land,
    denom_share_of_land,
    expiry_date,
    prop_details_date_changed,

    prop_address_id

FROM {{ ref('stg_cdm_property_event') }}
{%- if is_incremental() %}
WHERE date_changed > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(event_ts)') }} FROM {{ this }}), '1900-01-01')
{%- endif %}
ORDER BY event_ts
