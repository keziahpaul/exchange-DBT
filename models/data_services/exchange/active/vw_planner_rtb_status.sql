with source as (

    select * from {{  ref('pxa_planner_rtb_status') }}

),

renamed as (

    select
        pxa_planner_rtb_status_id,
        workspace_id,
        participant_id,
        status,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed