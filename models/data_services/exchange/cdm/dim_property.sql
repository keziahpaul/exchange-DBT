{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_update_columns = ['deleted_at']
    )
}}

WITH prop_src AS (
    SELECT DISTINCT
        id,
        date_changed,
        IFF(deleted, date_changed, NULL) AS deleted_at,
        workspace_id,
        land_identifier,
        date_added,
        lvreport_address,
        parent_indicator,
        ct_controller_abn,
        ct_controller_customer_code,
        ct_controller_name,
        lot_on_plan_id,
        interop_title_id
    FROM {{ ref('stg_cdm_property_event') }}
    {%- if is_incremental() %}
    WHERE date_changed > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(date_changed)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY id ORDER BY date_changed DESC)
)
SELECT
    id,
    date_changed,
    deleted_at,
    workspace_id,
    land_identifier,
    date_added,
    lvreport_address,
    parent_indicator,
    ct_controller_abn,
    ct_controller_customer_code,
    ct_controller_name,
    lot_on_plan_id,
    interop_title_id
FROM prop_src
ORDER BY id
