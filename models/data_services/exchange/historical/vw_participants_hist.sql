with source as (

    select * from {{ ref('pxa_participants') }}

),

renamed as (

    select
        participant_id,
        version,
        reference,
        default1,
        workspace_id,
        subscriber_id,
        workspace_role_id,
        dual_signing_settlement,
        signing_limit_sources,
        signing_limit_destinations,
        dual_signing_doc,
        status,
        dual_authorization,
        dual_authorization_limit,
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
        selected_link_participant,
        commercial_transaction_type,
        pexa_projects_id,
        pexa_projects_name,
        sett_items_status,
        sett_items_status_last_updated,
        has_disabled_auto_bal_source,
        workspace_health_indicator,
        rtb_confirmed,
        interop_participant_id,
        elno_id,
        subscriber_name,
        subscriber_abn,
        eln_subscriber_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed