with source as (

    select * from {{ ref('upload_job_items') }}

),

renamed as (

    select
        id,
        upload_job_id,
        data,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
