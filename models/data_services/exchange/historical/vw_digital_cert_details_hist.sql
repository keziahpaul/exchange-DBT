with source as (

    select * from {{ ref('pxa_digital_cert_details') }}

),

renamed as (

    select
        cert_details_id,
        user_email,
        cert_expiry,
        cert_issuer,
        os,
        os_type,
        software_version,
        cert_serial_number,
        last_modified_date,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed