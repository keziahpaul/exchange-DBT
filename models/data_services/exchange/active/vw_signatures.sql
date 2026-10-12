with source as (

    select * from {{  ref('pxa_signatures') }}

),

renamed as (

    select
        signature_id,
        date1,
        xml,
        workspace_role_id,
        user_id,
        xml_ref,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed