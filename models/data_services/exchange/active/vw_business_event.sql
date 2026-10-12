with source as (

    select * from {{ ref('pxa_business_event') }}

),

renamed as (

    select
        business_event_id,
        created_date,
        user_id,
        lodgement_case_id,
        subscriber_id,
        workspace_id,
        username,
        business_event_type_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed