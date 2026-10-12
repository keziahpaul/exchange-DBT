with source as (

    select * from {{ ref('pxa_imt_providers') }}

),

renamed as (

    select
        imt_provider_id,
        imt_name,
        imt_account_id,
        created_date,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed