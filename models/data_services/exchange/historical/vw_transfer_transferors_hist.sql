with source as (

    select * from {{  ref('pxa_transfer_transferors') }}

),

renamed as (

    select
        transfer_id,
        transferor_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed