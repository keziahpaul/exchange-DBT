with source as (

    select * from {{ ref('pxa_workspace_roles') }}

),

renamed as (

    select
        workspace_role_id,
        value,
        name,
        has_sett_access,
     effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed