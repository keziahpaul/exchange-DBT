with source as (

    select * from {{ ref('pxa_checklist_types') }}

),

renamed as (

    select
        checklist_type_id,
        description,
        checklist_group_type_id,
        is_active,
        business_event_prefix,
        help_text,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed