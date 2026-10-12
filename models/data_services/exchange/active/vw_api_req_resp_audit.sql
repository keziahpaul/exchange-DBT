with source as (

    select * from {{ ref('pxa_api_req_resp_audit') }}

),

renamed as (

    select
        api_req_resp_audit_id,
        uuid,
        username,
        request_ts,
        request_url,
        request_qry_string,
        request_headers,
        request_body,
        response_headers,
        response_body,
        request_headers_ref,
        request_body_ref,
        response_headers_ref,
        response_body_ref,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
        
    from source
      where effective_to::date = '{{var('active_date')}}'

)


select * from renamed