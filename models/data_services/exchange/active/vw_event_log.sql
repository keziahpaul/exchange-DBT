with source as (

    select * from {{ ref('pxa_event_log') }}

),

renamed as (

    select
        event_log_id,
        description,
        business_event_id,
        event_log_type_id,
        created_date,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed