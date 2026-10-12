with 

source as (

    select * from {{ ref('pxa_noa_details_list') }}

),

renamed as (

    select
        document_id,
        noa_details_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
