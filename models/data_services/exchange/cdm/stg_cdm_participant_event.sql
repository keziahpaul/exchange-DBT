{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'inserted_at']
    )
}}
{#- id is the participant_id -#}

WITH
{%- if is_incremental() %}
{#- only consider "new / updated" participants #}
participant_ids AS (
    SELECT DISTINCT
        participant_id
    FROM {{ ref('stg_pxa_participants') }}
    WHERE extraction_start_ts > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')::timestamp_ntz
),
{%- endif %}
participant_party AS (
    SELECT
        participant_id,
        party_id,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_participant_partys') }}
    {%- if is_incremental() %}
    JOIN participant_ids USING (participant_id)
    {%- endif %}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY participant_id, party_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
participant_group AS (
    SELECT
        pp.participant_id,
        NULLIF(LISTAGG(IFF(p.is_organisation, p.party_name, NULL), ', ') WITHIN GROUP (ORDER BY p.party_name), '') AS org_parties,
        SUM(IFF(p.is_organisation, 0, 1)) AS person_count
    FROM participant_party pp
    LEFT JOIN {{ ref('dim_party') }} p ON p.id = pp.party_id
    WHERE NOT pp.is_delete
    GROUP BY pp.participant_id
),
workgroup_workspace AS (
    SELECT
        workspace_id,
        workgroup_id,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_workgroup_workspaces') }}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY workspace_id, workgroup_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
workgroup_info AS (
    SELECT
        workspace_id,
        subscriber_id,
        name,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_workgroups') }}
    JOIN workgroup_workspace USING (workgroup_id)
    WHERE NOT workgroup_workspace.is_delete
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY workspace_id, workgroup_id, subscriber_id ORDER BY version DESC, extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
workgroups AS (
    SELECT
        workspace_id,
        subscriber_id,
        LISTAGG(DISTINCT name, ', ') WITHIN GROUP (ORDER BY name) AS workgroup_names
    FROM workgroup_info
    WHERE NOT is_delete
    GROUP BY workspace_id, subscriber_id
),
panel_member_source AS (
    SELECT
        panel_member_id,
        op = 'D' AS is_delete
    FROM {{ ref('stg_pxa_subscriber_panel_members') }}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY subscriber_id, panel_member_id ORDER BY extraction_start_ts DESC, transact_seq DESC NULLS LAST)
),
panel_members AS (
    SELECT DISTINCT
        panel_member_id
    FROM panel_member_source
    WHERE NOT is_delete
),
participants_src AS (
    SELECT
        participant_id,
        ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST) AS rn,
        op = 'D' AS is_delete,
        extraction_start_ts,
        HASH(
            reference,
            workspace_id,
            subscriber_id,
            workspace_role_id,
            dual_signing_settlement,
            dual_signing_doc,
            status,
            dual_authorization,
            pexa_projects_id,
            pexa_projects_name,
            acceptance_status,
            accepted_by,
            settle_acceptance_status,
            user_id,
            settle_accepted_date,
            settle_accept_by_username,
            settle_accept_by_subscriber_id,
            settle_accept_by_system_user,
            withdraw_reason,
            withdraw_info,
            is_delete
        ) AS r_hash,
        reference,
        workspace_id,
        subscriber_id,
        workspace_role_id,
        dual_signing_settlement,
        dual_signing_doc,
        status,
        dual_authorization,
        pexa_projects_id,
        pexa_projects_name,
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
    FROM {{ ref('stg_pxa_participants') }}
    {%- if is_incremental() %}
    JOIN participant_ids USING (participant_id)
    {%- endif %}
    QUALIFY r_hash IS DISTINCT FROM LAG(r_hash) OVER (PARTITION BY participant_id ORDER BY version, extraction_start_ts, transact_seq NULLS FIRST)
),
participants_pre AS (
    SELECT
        participant_id,
        rn AS transact_seq,
        is_delete,
        extraction_start_ts,
        IFF(is_delete, LAG(reference) OVER (PARTITION BY participant_id ORDER BY rn), reference) AS reference,
        IFF(is_delete, LAG(workspace_id) OVER (PARTITION BY participant_id ORDER BY rn), workspace_id) AS workspace_id,
        IFF(is_delete, LAG(subscriber_id) OVER (PARTITION BY participant_id ORDER BY rn), subscriber_id) AS subscriber_id,
        IFF(is_delete, LAG(workspace_role_id) OVER (PARTITION BY participant_id ORDER BY rn), workspace_role_id) AS workspace_role_id,
        IFF(is_delete, LAG(dual_signing_settlement) OVER (PARTITION BY participant_id ORDER BY rn), dual_signing_settlement) AS dual_signing_settlement,
        IFF(is_delete, LAG(dual_signing_doc) OVER (PARTITION BY participant_id ORDER BY rn), dual_signing_doc) AS dual_signing_doc,
        IFF(is_delete, LAG(status) OVER (PARTITION BY participant_id ORDER BY rn), status) AS status,
        IFF(is_delete, LAG(dual_authorization) OVER (PARTITION BY participant_id ORDER BY rn), dual_authorization) AS dual_authorization,
        IFF(is_delete, LAG(pexa_projects_id) OVER (PARTITION BY participant_id ORDER BY rn), pexa_projects_id) AS pexa_projects_id,
        IFF(is_delete, LAG(pexa_projects_name) OVER (PARTITION BY participant_id ORDER BY rn), pexa_projects_name) AS pexa_projects_name,
        IFF(is_delete, LAG(acceptance_status) OVER (PARTITION BY participant_id ORDER BY rn), acceptance_status) AS acceptance_status,
        IFF(is_delete, LAG(accepted_by) OVER (PARTITION BY participant_id ORDER BY rn), accepted_by) AS accepted_by,
        IFF(is_delete, LAG(settle_acceptance_status) OVER (PARTITION BY participant_id ORDER BY rn), settle_acceptance_status) AS settle_acceptance_status,
        IFF(is_delete, LAG(user_id) OVER (PARTITION BY participant_id ORDER BY rn), user_id) AS user_id,
        IFF(is_delete, LAG(settle_accepted_date) OVER (PARTITION BY participant_id ORDER BY rn), settle_accepted_date) AS settle_accepted_date,
        IFF(is_delete, LAG(settle_accept_by_username) OVER (PARTITION BY participant_id ORDER BY rn), settle_accept_by_username) AS settle_accept_by_username,
        IFF(is_delete, LAG(settle_accept_by_subscriber_id) OVER (PARTITION BY participant_id ORDER BY rn), settle_accept_by_subscriber_id) AS settle_accept_by_subscriber_id,
        IFF(is_delete, LAG(settle_accept_by_system_user) OVER (PARTITION BY participant_id ORDER BY rn), settle_accept_by_system_user) AS settle_accept_by_system_user,
        IFF(is_delete, LAG(withdraw_reason) OVER (PARTITION BY participant_id ORDER BY rn), withdraw_reason) AS withdraw_reason,
        IFF(is_delete, LAG(withdraw_info) OVER (PARTITION BY participant_id ORDER BY rn), withdraw_info) AS withdraw_info
    FROM participants_src
),
participants AS (
    SELECT
        participant_id,
        is_delete,
        {{ dms_timestampntz_us_to_ns('extraction_start_ts', ['participant_id'], [], 'Australia/Sydney') }} AS inserted_at,
        reference AS subscriber_reference,
        workspace_id,
        subscriber_id,
        workspace_role_id,
        dual_signing_settlement,
        dual_signing_doc AS dual_signing_document,
        status AS participant_status,
        dual_authorization AS dual_authorisation,
        pexa_projects_id AS pexa_project_id,
        pexa_projects_name AS pexa_project_name,
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
    FROM participants_pre
),
participant_event AS (
    SELECT
        p.participant_id AS id,
        p.subscriber_reference,
        p.workspace_id,
        p.subscriber_id,
        pm.panel_member_id IS NOT NULL AS is_panel_master,
        se.name AS subscriber_name,
        se.subscriber_type AS subscriber_type,
        se.subscriber_category AS subscriber_category,
        wg.workgroup_names AS workgroup,
        CASE
        WHEN pg.org_parties IS NOT NULL AND pg.person_count > 0 THEN 'INDIVIDUAL, ' || pg.org_parties
        WHEN pg.org_parties IS NOT NULL THEN pg.org_parties
        WHEN pg.person_count > 0 THEN 'INDIVIDUAL'
        END AS party_represented,
        p.workspace_role_id,
        p.dual_signing_settlement,
        p.dual_signing_document,
        p.participant_status,
        p.dual_authorisation,
        p.pexa_project_id,
        p.pexa_project_name,
        p.acceptance_status,
        p.accepted_by,
        p.settle_acceptance_status,
        p.user_id,
        {{ timestampntz_to_tz('settle_accepted_date', 'Australia/Sydney') }} AS settle_accepted_date,
        p.settle_accept_by_username,
        p.settle_accept_by_subscriber_id,
        p.settle_accept_by_system_user,
        p.withdraw_reason,
        p.withdraw_info,
        COALESCE(wr.enum_name, wr_default.enum_name) AS workspace_role,
        p.is_delete,
        p.inserted_at
    FROM participants p
    JOIN {{ ref('fact_subscriber_event') }} se ON p.subscriber_id = se.id
    LEFT JOIN participant_group pg USING (participant_id)
    LEFT JOIN panel_members pm ON pm.panel_member_id = p.subscriber_id
    LEFT JOIN workgroups wg ON wg.subscriber_id = p.subscriber_id AND wg.workspace_id = p.workspace_id
    LEFT JOIN {{ ref('enum_workspace_role') }} wr ON wr.enum_value = p.workspace_role_id,
    {{ ref('enum_workspace_role') }} wr_default
    WHERE wr_default.is_default
    {%- if is_incremental() %}
      AND inserted_at > COALESCE((SELECT MAX(inserted_at) FROM {{ this }}), '1900-01-01')
    {%- endif %}
    {#- Only pick the record with the most recent subscriber event prior to this, else the soonest after this participant event for names #}
    QUALIFY 1 = ROW_NUMBER() OVER (PARTITION BY p.participant_id, p.inserted_at ORDER BY IFF(se.event_ts <= p.inserted_at, 0, 1) ASC, ABS(se.event_ts - p.inserted_at) ASC)
)
SELECT
    p.id,                                                {#- dim/fact #}
    p.workspace_id,                                      {#- dim #}
    p.subscriber_id,                                     {#- dim #}
    p.workspace_role,                                    {#- dim #}
    p.subscriber_reference,                              {#- fact #}
    p.workspace_role_id,                                 {#- dim #}
    p.dual_signing_settlement,                           {#- fact #}
    p.dual_signing_document,                             {#- fact #}
    p.participant_status,                                {#- fact #}
    p.dual_authorisation,                                {#- fact #}
    p.pexa_project_id,                                   {#- fact #}
    p.pexa_project_name,                                 {#- fact #}
    p.acceptance_status,                                 {#- fact #}
    p.accepted_by,                                       {#- fact #}
    p.settle_acceptance_status,                          {#- fact #}
    p.user_id,                                           {#- fact #}
    p.settle_accepted_date,                              {#- fact #}
    p.settle_accept_by_username,                         {#- fact #}
    p.settle_accept_by_subscriber_id,                    {#- fact #}
    p.settle_accept_by_system_user,                      {#- fact #}
    p.withdraw_reason,                                   {#- fact #}
    p.withdraw_info,                                     {#- fact #}
    {#- business_unit, This is business logic based on
        subscriber_id, subscriber_reference, and workspace_role_id #}
    p.is_panel_master,                                   {#- fact #}
    p.subscriber_name,                                   {#- fact #}
    p.subscriber_type,                                   {#- fact #}
    p.subscriber_category,                               {#- fact #}
    p.workgroup,                                         {#- dim #}
    p.party_represented,                                 {#- dim #}
    p.inserted_at,                                       {#- dim/fact #}
    IFF(p.is_delete, p.inserted_at, NULL) AS deleted_at  {#- dim #}
FROM participant_event p
ORDER BY p.inserted_at
