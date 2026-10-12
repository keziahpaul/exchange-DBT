with 

source as (

    select * from {{ ref('pxa_prop_info_prop') }}

),

renamed as (

    select
        property_information_detail_id,
        transfer_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
