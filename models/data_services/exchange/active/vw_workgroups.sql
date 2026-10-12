with source as (

    select * from {{  ref('pxa_workgroups') }}

),

renamed as (

    select
        workgroup_id,
        version,
        name,
        subscriber_id,
        description,
        is_parent,
        email_address,
        parent_workgroup_id,
        hierarchy,
        mobile_number,
     effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed