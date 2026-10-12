with source as (

    select * from {{ ref('pxa_operating_jurisdiction') }}

),

renamed as (

    select
        opera_jurisdiction_id,
        jurisdiction_status,
        customer_code,
        jurisdiction,
        customeraccountupdatexml,
        date_status_lrupdate,
        status_reason_change,
        status_change_date,
        status_change_user,
        customer_update_status,
        osr_client_id,
        customeraccountupdatexml_ref,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed