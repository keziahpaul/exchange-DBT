with source as (

    select * from {{ ref('pxa_group_proprietors') }}

),

renamed as (

    select
        proprietor_group_id,
        party_id,
        inserted_at
    from source

)


select * from renamed