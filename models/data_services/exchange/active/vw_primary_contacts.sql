with source as (

    select * from {{  ref('pxa_primary_contacts') }}

),

renamed as (

    select
        primary_contact_id,
        version,
        preference,
        user_id,
       effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed