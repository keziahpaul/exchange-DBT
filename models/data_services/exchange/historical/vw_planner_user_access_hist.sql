with source as (

    select * from {{  ref('pxa_planner_user_access') }}

),

renamed as (

    select
        user_id,
        subscriber_id,
        has_pexa_planner_access,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)


select * from renamed