with source as (

    select * from {{ ref('authority') }}

),

renamed as (

    select
        role,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
