with source as (

    select * from {{ ref('pxa_residual_configs') }}

),

renamed as (

    select
        residual_config_id,
        jurisdiction,
        document_category,
        document_name,
        sub_category,
        form_name,
        document_type,
        usage_description,
        is_active,
        product_code,
        json_config,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
