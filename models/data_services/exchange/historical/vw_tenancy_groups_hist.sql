with source as (

    select * from {{  ref('pxa_tenancy_groups') }}

),

renamed as (

    select
        proprietor_group_id,
        tenancy_detail_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed