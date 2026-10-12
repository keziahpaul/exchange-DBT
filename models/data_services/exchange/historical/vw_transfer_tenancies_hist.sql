with source as (

    select * from {{  ref('pxa_transfer_tenancies') }}

),

renamed as (

    select
        tenancy_detail_id,
        transfer_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed