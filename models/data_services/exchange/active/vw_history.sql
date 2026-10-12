with source as (

    select * from {{ ref('pxa_history') }}

),

renamed as (

    select
        history_id,
        version,
        user_id,
        history_timestamp,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed