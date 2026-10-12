{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'date_changed']
    )
}}
{#- id is the property_id -#}

WITH prop_det AS (
    SELECT
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['property_detail_id'], ['extraction_start_ts'], 'Australia/Sydney') }} AS date_changed,
        property_detail_id,
	    {{ timestampntz_to_tz('issued', 'Australia/Sydney') }} AS issued, -- this is a Sydney timestamp in NTZ
	    description,
	    estate_type,
	    address,
	    bundle_subscription,
	    duplicate_ct_issued,
	    cert_of_title_details_id,
	    positive_tac_flag,
	    tac_failure_flag,
	    address_id,
	    title_type,
	    sub_jurisdiction,
	    numerator_share_of_land,
	    denom_share_of_land,
	    expiry_date
    FROM {{ref('stg_pxa_property_details')}}
    {#- this table only ever has inserts and deletes #}
    {#- when op = 'D' all values are null #}
    WHERE op = 'I'
    {#- workaround to exclude DMS duplicate data, want first time we saw this record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY property_detail_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST)
),
prop_add AS (
    SELECT
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['property_id'], ['extraction_start_ts'], 'Australia/Sydney') }} AS date_changed,
        property_id,
        address_id
    FROM {{ref('stg_pxa_propertys_address')}}
    {#- SQL says PK is property_id, address_id. #}
    {#- Java actually treats property_id and address_id as individually unique #}
    {#- Java targets this table through property_id #}
    WHERE op <> 'D'
    {#- workaround to exclude DMS duplicate data, going to take the final address_id seen #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY property_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
spp_with_lag as (
    SELECT
        extraction_start_ts,
        transact_seq,
        property_id,
        IFF(op = 'D', LAG(property_detail_id) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), property_detail_id) AS property_detail_id,
        IFF(op = 'D', LAG(workspace_id) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), workspace_id) AS workspace_id,
        IFF(op = 'D', LAG(land_identifier) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), land_identifier) AS land_identifier,
        IFF(op = 'D', LAG(date_added) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), date_added) AS date_added,
        IFF(op = 'D', LAG(lvreport_address) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), lvreport_address) AS lvreport_address,
        IFF(op = 'D', LAG(updated_address_display) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), updated_address_display) AS updated_address_display,
        IFF(op = 'D', LAG(parent_indicator) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), parent_indicator) AS parent_indicator,
        IFF(op = 'D', LAG(initial_ris_date) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), initial_ris_date) AS initial_ris_date,
        IFF(op = 'D', LAG(lot_in_unregistered_plan) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), lot_in_unregistered_plan) AS lot_in_unregistered_plan,
        IFF(op = 'D', LAG(ltrv_warning_code) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), ltrv_warning_code) AS ltrv_warning_code,
        IFF(op = 'D', LAG(ct_controller_abn) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), ct_controller_abn) AS ct_controller_abn,
        IFF(op = 'D', LAG(ct_controller_customer_code) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), ct_controller_customer_code) AS ct_controller_customer_code,
        IFF(op = 'D', LAG(ct_controller_name) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), ct_controller_name) AS ct_controller_name,
        IFF(op = 'D', LAG(lot_on_plan_id) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), lot_on_plan_id) AS lot_on_plan_id,
        IFF(op = 'D', LAG(interop_title_id) OVER (PARTITION BY property_id ORDER BY extraction_start_ts, transact_seq NULLS FIRST), interop_title_id) AS interop_title_id,
        (op = 'D') AS deleted
    FROM {{ ref('stg_pxa_propertys') }} p
    {#- only [property_detail_id, updated_address_display, initial_ris_date, lot_in_unregistered_plan, ltrv_warning_code] ever change, apparently #}
    {#- when the op = 'D', all values other the property_id are null #}
    {#- the first real record must have a property_detail_id, initial_ris_date or land_identifier #}
    WHERE (property_detail_id IS NOT NULL
       OR initial_ris_date IS NOT NULL
       OR land_identifier IS NOT NULL
       OR op = 'D')
    {%- if is_incremental() %}
    {#- remember to remove the nanoseconds adjustment for incremental load comparison and convert back to timestamp_ntz #}
      AND extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(date_changed)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
    {%- endif %}
),
spp AS (
    SELECT
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['property_id', 'date_added'], ['extraction_start_ts'], 'Australia/Sydney') }} AS date_changed,
        property_id,
        property_detail_id,
        workspace_id,
        land_identifier,
        {{ timestampntz_to_tz('date_added', 'Australia/Sydney') }} AS date_added,
        lvreport_address,
        updated_address_display,
        parent_indicator,
        {{ timestampntz_to_tz('initial_ris_date', 'Australia/Sydney') }} AS initial_ris_date,
        lot_in_unregistered_plan,
        ltrv_warning_code,
        ct_controller_abn,
        ct_controller_customer_code,
        ct_controller_name,
        lot_on_plan_id,
        interop_title_id,
        deleted
    FROM spp_with_lag
    {#- final check post LAG #}
    WHERE (property_detail_id IS NOT NULL
       OR initial_ris_date IS NOT NULL
       OR land_identifier IS NOT NULL)
    {#- workaround to exclude DMS duplicate data, want first time we saw this record #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY property_id, date_added ORDER BY deleted DESC, extraction_start_ts, transact_seq NULLS FIRST)
)

SELECT
    spp.property_id AS id,
    spp.date_changed,
    spp.deleted,
    spp.property_detail_id,
    spp.workspace_id,
    spp.land_identifier,
    spp.date_added,
    spp.lvreport_address,
    spp.updated_address_display,
    spp.parent_indicator,
    spp.initial_ris_date,
    spp.lot_in_unregistered_plan,
    spp.ltrv_warning_code,
    spp.ct_controller_abn,
    spp.ct_controller_customer_code,
    spp.ct_controller_name,
    spp.lot_on_plan_id,
    spp.interop_title_id,

    prop_det.address,
    prop_det.estate_type,
    prop_det.issued,
    prop_det.description,
    prop_det.bundle_subscription,
    prop_det.duplicate_ct_issued,
    prop_det.cert_of_title_details_id,
    prop_det.positive_tac_flag,
    prop_det.tac_failure_flag,
    prop_det.address_id AS prop_details_address_id,
    prop_det.title_type,
    prop_det.sub_jurisdiction,
    prop_det.numerator_share_of_land,
    prop_det.denom_share_of_land,
    prop_det.expiry_date,
    prop_det.date_changed AS prop_details_date_changed,

    prop_add.address_id AS prop_address_id
from spp
left join prop_det
    on spp.property_detail_id = prop_det.property_detail_id
left join prop_add
    on spp.property_id = prop_add.property_id
ORDER BY spp.date_changed
