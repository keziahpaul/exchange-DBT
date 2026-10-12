with source as (

    select * from {{ ref('pxa_residuals') }}

),

renamed as (

    select
        document_id,
        config_data,
        config_id,
        stylesheet_version,
        data_values,
        data_values_ref,
        config_data_ref,
        compliance_data_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
