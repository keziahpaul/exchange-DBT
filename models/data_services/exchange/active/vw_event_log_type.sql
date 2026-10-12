with source as (

    select * from {{ ref('pxa_event_log_type') }}

),

renamed as (

    select
        event_log_type_id,
        description_template,
        business_event_type_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed