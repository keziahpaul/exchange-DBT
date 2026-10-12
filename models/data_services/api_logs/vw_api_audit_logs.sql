

with source as (

    select * from {{ ref('curate_api_audit_logs') }}

),

renamed as (

    select
        ID,
        REQUEST_BODY,
        REQUEST_BODY_REF,
        REQUEST_BODY_S3,
        REQUEST_HEADERS,
        REQUEST_HEADERS_REF,
        REQUEST_HEADERS_S3,
        REQUEST_QRY_STRING,
        REQUEST_TIMESTAMP,
        REQUEST_URL,
        RESPONSE_BODY,
        RESPONSE_BODY_REF,
        RESPONSE_BODY_S3,
        RESPONSE_HEADERS,
        RESPONSE_HEADERS_REF,
        RESPONSE_HEADERS_S3,
        USERNAME,
        UUID,
        SRC_INSERTED_AT,
        INSERTED_AT

    from source

)


select * from renamed