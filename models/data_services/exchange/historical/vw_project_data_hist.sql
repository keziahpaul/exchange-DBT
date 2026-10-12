with 

source as (

    select * from {{ ref('pxa_project_data') }}

),

renamed as (

    select
        project_data_id,
        pexa_projects_id,
        pexa_projects_name,
        intend_to_lock,
        subscriber_id,
        role_id,
        restrict_settlement_dates,
        project_supplier_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
