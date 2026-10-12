{{ config(
    materialized='incremental',
    incremental_strategy='append',
) }}

    select distinct
        data:id::VARCHAR as id,
        data:requestBody::VARCHAR as request_body,
        data:requestBodyRef::VARCHAR as request_body_ref,
        data:requestBodyS3::VARCHAR as request_body_s3,
        data:requestHeaders::VARCHAR as request_headers,
        data:requestHeadersRef::VARCHAR as request_headers_ref,
        data:requestHeadersS3::VARCHAR as request_headers_s3,
        data:requestQryString::VARCHAR as request_qry_string,
        REPLACE(data:requestTimestamp, 'T', ' ')::TIMESTAMP_NTZ  AS request_timestamp, 
        data:requestUrl::VARCHAR as request_url,
        data:responseBody::VARCHAR as response_body,
        data:responseBodyRef::VARCHAR as response_body_ref,
        data:responseBodyS3::VARCHAR as response_body_s3,
        data:responseHeaders::VARCHAR as response_headers,
        data:responseHeadersRef::VARCHAR as response_headers_ref,
        data:responseHeadersS3::VARCHAR as response_headers_s3,
        data:username::VARCHAR as username,
        data:uuid::VARCHAR as uuid,
        inserted_at as src_inserted_at,
        {{ var('inserted_at') }} as inserted_at
    from {{ ref('api_audit_logs') }}

    {% if is_incremental() %}
        where inserted_at > (select coalesce(max(src_inserted_at), '1900-01-01 00:00:00') from {{ this }}) 
    {% endif %}
