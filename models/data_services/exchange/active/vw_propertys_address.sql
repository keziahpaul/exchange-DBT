with source as (

    select * from {{  ref('pxa_propertys_address') }}

),

renamed as (

    select
        address_id,
        property_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed