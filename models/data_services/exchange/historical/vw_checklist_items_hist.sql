with source as (

    select * from {{ ref('pxa_checklist_items') }}

),

renamed as (

    select
        checklist_item_id,
        description,
        is_checked,
        checked_date,
        checklist_group_id,
        checked_by,
        participant,
        checklist_type,
        subscriber_name,
        subscriber_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed