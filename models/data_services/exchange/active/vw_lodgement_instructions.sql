with source as (

    select * from {{ ref('pxa_lodgement_instructions') }}

),

renamed as (

    select
        document_id,
        subscriber_id,
        reference_id,
        client_reference,
        party_id,
        address_id,
        priority_notice_id,
        responsible_subs_signing_flag,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed