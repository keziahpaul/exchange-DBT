with source as (

    select * from {{ ref('pxa_business_event_types') }}

),

renamed as (

    select
        business_event_type_id,
        name,
        description,
        business_event_category_id,
        workspace_related,
        action_required,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed