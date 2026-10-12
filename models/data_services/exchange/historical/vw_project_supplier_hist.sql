with 

source as (

    select * from {{ ref('pxa_project_supplier') }}

),

renamed as (

    select
        project_supplier_id,
        name,
        abn,
        address_line_1,
        address_line_2,
        suburb,
        postcode,
        state,
        email,
        phone,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
