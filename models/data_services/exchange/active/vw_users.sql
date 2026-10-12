with source as (

    select * from {{ ref('pxa_users') }}

),

renamed as (

    select
        user_id,
        version,
        username,
        first_name,
        middle_name,
        last_name,
        email_address1,
        phone_number,
        job_title,
        created,
        status,
        subscriber_id,
        address_id,
        deleted,
        reason,
        reason_username,
        reason_date,
        default_jurisdiction,
        source_signing_limit,
        destination_signing_limit,
        trust_source_signing_limit,
        deletion_date,
        reinstate_date,
        reinstate_user_id,
        reinstate_reason,
        archive_date,
        archiving_user_id,
        aus_legal_practitioner,
        certifier_designation,
        created_by_user_id,
        common_signature_id,
        first_name_pronunciation,
        middle_name_pronunciation,
        last_name_pronunciation,
        preferred_name,
        pronouns,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed