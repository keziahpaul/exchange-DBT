with source as (

    select * from {{ ref('api_usage_audit') }}

),

renamed as (

    select
        id,
        endpoint_name,
        project_id,
        project_name,
        pexa_core_workspace_id,
        oauth_grant_type,
        integrator,
        integrator_type,
        authorised_party,
        subscriber_id,
        email,
        created_at,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
