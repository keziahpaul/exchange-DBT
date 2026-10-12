with source as (

    select * from {{ ref('project') }}

),

renamed as (

    select
        id,
        subscriber_id,
        data,
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
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
