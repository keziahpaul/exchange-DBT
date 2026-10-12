{{
    config(
        materialized = 'incremental',
        unique_key = 'id'
    )
}}
{#- If you change the structure of this model, you will need to do a full refresh of the CDM of this model and downstream -#}

{#- do we even need the bool_states CTE here?
    * disburse_interim_flag
    * new_fss_on
    * auto_calculate_vendor_surplus
    * fss_partial_view
    * is_interop_fss_ready
    * interop_settlement_status
    * interop_settlement_lock_status
 #}
WITH bool_states AS (
    SELECT bool_state, is_default
    FROM (VALUES
        (FALSE, TRUE),
        (TRUE, FALSE)
        {#- does not require a NULL row as default for boolean fields is false #}
    ) v(bool_state, is_default)
{%- if is_incremental() %}
    WHERE GREATEST_IGNORE_NULLS(
        (SELECT MAX(created_on) FROM {{ref('enum_link_type')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_rits_status')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_settlement_status')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_settlement_type')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_settlement_tracking_status')}}),
        '1900-01-01'
    ) > COALESCE((SELECT MAX(created_on) FROM {{ this }}), '1900-01-01')
{%- endif %}
)
SELECT
    HASH(lt.enum_name, rs.enum_name, ss.enum_name, st.enum_name, sts.enum_name) AS id,
    GREATEST_IGNORE_NULLS(lt.created_on, rs.created_on, ss.created_on, st.created_on, sts.created_on) AS created_on,
    {#- This does not include lodgement_case_status or settlement_status as they are dependent on workspace_status #}
    (lt.is_default AND rs.is_default AND ss.is_default AND st.is_default AND sts.is_default) AS is_default_row_for_null,

    lt.enum_name AS link_type,
    lt.enum_value AS link_type_description,
    lt.settlement_type AS link_type_settlement_type,
    lt.execution_type AS link_type_execution_type,

    rs.enum_name AS rits_status,
    rs.is_past_reservation AS rits_is_past_reservation,

    ss.enum_name AS settlement_status,
    ss.enum_value AS settlement_status_description,
    ss.settled AS settlement_settled,
    ss.ge_than_settling AS settlement_ge_than_settling,
    ss.ge_than_signed AS settlement_ge_than_signed,
    ss.locked AS settlement_locked,
    ss.unlocked AS settlement_unlocked,

    st.enum_name AS settlement_type,
    st.is_esettle AS settlement_type_is_esettle,
    st.is_elodge AS settlement_type_is_elodge,

    sts.enum_name AS settlement_tracking_status,
    sts.enum_value AS sts_description,
    sts.step1 AS sts_step1,
    sts.step2 AS sts_step2,
    sts.heirarchy AS sts_heirarchy,
    sts.is_success AS sts_is_success,
    sts.is_failed AS sts_is_failed,
    sts.is_timeout AS sts_is_timeout,
    sts.is_settled AS sts_is_settled,
    sts.is_rits_update AS sts_is_rits_update,
    sts.is_in_cutoff_status AS sts_is_in_cutoff_status,
    sts.is_rits_settlement_tech_error AS sts_is_rits_settlement_tech_error

FROM {{ref('enum_link_type')}} lt
, {{ref('enum_rits_status')}} rs
, {{ref('enum_settlement_status')}} ss
, {{ref('enum_settlement_type')}} st
, {{ref('enum_settlement_tracking_status')}} sts
ORDER BY id
