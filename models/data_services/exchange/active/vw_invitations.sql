with source as (

    select * from {{ ref('pxa_invitations') }}

),

renamed as (

    select
        invitation_id,
        version,
        reference,
        notes,
        status,
        created,
        workspace_role_id,
        workspace_id,
        from_subscriber_id,
        to_subscriber_id,
        workgroup_id,
        from_user_id,
        decline_reason_type,
        decline_reason_addtl,
        forwardedto_subscriber_id,
        disposition_status,
        forwardedby_subscriber_id,
        date_accepted,
        date_declined,
        account_number,
        from_business_unit_type,
        property_address,
        party_represented,
        other_parties,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed