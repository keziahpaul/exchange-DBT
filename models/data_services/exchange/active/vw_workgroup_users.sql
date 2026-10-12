with source as (

    select * from {{  ref('pxa_workgroup_users') }}

),

renamed as (

    select
        user_id,
        workgroup_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed