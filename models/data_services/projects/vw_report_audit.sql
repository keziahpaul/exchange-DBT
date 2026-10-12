with source as (

    select * from {{ ref('report_audit') }}

),

renamed as (

    select
        id,
        created_at,
        username,
        project_id,
        subscriber_id,
        report_type,
        input_parameters,
        external_api,
        jurisdiction,
        project_name,
        subscriber_name,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
