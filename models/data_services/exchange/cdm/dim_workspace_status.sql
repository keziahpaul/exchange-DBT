{{
    config(
        materialized = 'incremental',
        unique_key = 'id'
    )
}}
{#- If you change the structure of this model, you will need to do a full refresh of the CDM of this model and downstream -#}

WITH bool_states AS (
    SELECT bool_state, is_default
    FROM (VALUES
        (FALSE, TRUE),
        (TRUE, FALSE)
        {#- does not require a NULL row as default for boolean fields is false #}
    ) v(bool_state, is_default)
{%- if is_incremental() %}
    WHERE GREATEST_IGNORE_NULLS(
        (SELECT MAX(created_on) FROM {{ref('enum_workspace_status')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_lodgement_case_status')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_settlement_status')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_privacy')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_workspace_transaction_type')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_workspace_transaction_scope')}}),
        (SELECT MAX(created_on) FROM {{ref('enum_iop_workspace_lock_status')}}),
        '1900-01-01'
    ) > COALESCE((SELECT MAX(created_on) FROM {{ this }}), '1900-01-01')
{%- endif %}
)
SELECT
    HASH(ws.enum_name, p.enum_name, wtt.enum_name, wts.enum_name, panel_master_selected.bool_state,
         is_ready_to_book.bool_state, is_interop.bool_state, is_interop_ready.bool_state, iwls.enum_name,
         is_interop_archived.bool_state, is_pelno.bool_state, is_reverted_to_regular_refi.bool_state) AS id,
    GREATEST_IGNORE_NULLS(ws.created_on, lcs.created_on, ss.created_on, p.created_on,
                          wtt.created_on, wts.created_on, iwls.created_on) AS created_on,
    {#- This does not include lodgement_case_status or settlement_status as they are dependent on workspace_status #}
    (ws.is_default AND p.is_default AND wtt.is_default AND wts.is_default AND panel_master_selected.is_default AND
     is_ready_to_book.is_default AND is_interop.is_default AND is_interop_ready.is_default AND iwls.is_default AND
     is_interop_archived.is_default AND is_pelno.is_default AND is_reverted_to_regular_refi.is_default
    ) AS is_default_row_for_null,

    ws.enum_name AS workspace_status,
    ws.enum_value AS workspace_status_description,
    ws.locked AS workspace_locked,
    ws.not_abandoned AS workspace_not_abandoned,
    ws.active AS workspace_active,
    ws.in_progress AS workspace_in_progress,
    ws.in_prep AS workspace_in_prep,
    ws.sett_trans_dashboard_status AS workspace_sett_trans_dashboard_status,
    ws.ready AS workspace_ready,

    ws.lodgement_name AS lodgement_status,
    lcs.enum_value AS lodgement_description,
    lcs.locked AS lodgement_locked,
    lcs.lodging AS lodgement_lodging,
    lcs.greater_than_in_prep AS lodgement_greater_than_in_prep,
    lcs.less_than_ready AS lodgement_less_than_ready,
    lcs.active AS lodgement_active,

    ws.settlement_name AS settlement_status,
    ss.enum_value AS settlement_status_description,
    ss.settled AS settlement_settled,
    ss.ge_than_settling AS settlement_ge_than_settling,
    ss.ge_than_signed AS settlement_ge_than_signed,
    ss.locked AS settlement_locked,
    ss.unlocked AS settlement_unlocked,

    p.enum_name AS privacy,

    wtt.enum_name AS transaction_type,
    wtt.enum_value AS transaction_type_description,
    wtt.default_financial_settlement_flag,
    wtt.default_involve_transfer_flag,
    wtt.not_involved_in_transfer,
    wtt.has_optional_settle_datetime,

    wts.enum_name AS transaction_scope,
    wts.enum_value AS transaction_scope_description,

    panel_master_selected.bool_state AS panel_master_selected,
    is_ready_to_book.bool_state AS is_ready_to_book,
    is_interop.bool_state AS is_interop,
    is_interop_ready.bool_state AS is_interop_ready,
    iwls.enum_name AS interop_lock_status,
    is_interop_archived.bool_state AS is_interop_archived,
    is_pelno.bool_state AS is_pelno,
    is_reverted_to_regular_refi.bool_state AS is_reverted_to_regular_refi

FROM {{ref('enum_workspace_status')}} ws
LEFT JOIN {{ref('enum_lodgement_case_status')}} lcs ON lcs.enum_name = ws.lodgement_name
LEFT JOIN {{ref('enum_settlement_status')}} ss ON ss.enum_name = ws.settlement_name
, {{ref('enum_privacy')}} p
, {{ref('enum_workspace_transaction_type')}} wtt
, {{ref('enum_workspace_transaction_scope')}} wts
, bool_states panel_master_selected
, bool_states is_ready_to_book
, bool_states is_interop
, bool_states is_interop_ready
, {{ref('enum_iop_workspace_lock_status')}} iwls
, bool_states is_interop_archived
, bool_states is_pelno
, bool_states is_reverted_to_regular_refi
ORDER BY id
