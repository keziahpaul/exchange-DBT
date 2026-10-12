with source as (

    select * from {{ ref('invitation_job_item') }}

),

renamed as (

    select
        id,
        invitation_job_id,
        data,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
