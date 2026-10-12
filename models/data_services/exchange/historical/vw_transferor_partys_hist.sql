with source as (

    select * from {{  ref('pxa_transferor_partys') }}

),

renamed as (

    select
        party_id,
        transferor_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed