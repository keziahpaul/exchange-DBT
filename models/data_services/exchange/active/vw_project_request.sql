with source as (

    select * from {{  ref('pxa_project_request') }}

),

renamed as (

    select
        project_request_id,
        version,
        pexa_projects_id,
        status,
        created,
        reference,
        notes,
        party_represented,
        est_settlement_date,
        workspace_role_id,
        from_subscriber_id,
        to_subscriber_id,
        forwardedby_subscriber_id,
        forwardedto_subscriber_id,
        workgroup_id,
        from_user_id,
        decline_reason_type,
        decline_reason_addtl,
        land_identifier,
        pexa_projects_name,
        jurisdiction,
        mot_pexa_projects_name,
        commercial_transaction_type,
        mortgagee_name,
        panelmaster_subscriber_id,
        accepted,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed