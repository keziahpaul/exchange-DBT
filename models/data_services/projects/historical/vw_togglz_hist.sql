with source as (

    select * from {{ ref('togglz') }}

),

renamed as (

    select
        feature_name,
        feature_enabled,
        strategy_id,
        strategy_params,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
