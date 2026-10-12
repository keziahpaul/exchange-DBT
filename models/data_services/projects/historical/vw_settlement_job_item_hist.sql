with source as (

    select * from {{ ref('settlement_job_item') }}

),

renamed as (

    select
        id,
        settlement_job_id,
        data,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
