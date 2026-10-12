with source as (

    select * from {{ ref('pd_user') }}

),

renamed as (

    select
        id,
        email,
        subscriber_id,
        first_name,
        last_name,
        subscriber_name,
        type,
        workgroups,
        subscriber_dual_sign_fss,
        subscriber_dual_sign_doc,
        user_permissions,
        created_on,
        created_by,
        last_modified_on,
        last_modified_by,
        version,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
