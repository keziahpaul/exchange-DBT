with source as (

    select * from {{ ref('mot_project') }}

),

renamed as (

    select
        id,
        name,
        subscriber_id,
        project_id,
        created_at,
        subscriber_reference_prefix,
        status,
        account_details_data,
        version,
        created_on,
        created_by,
        last_modified_on,
        last_modified_by,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
