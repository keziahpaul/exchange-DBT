{{ config(
    materialized='incremental',
    incremental_strategy='append',
    cluster_by = ['request_timestamp_aest::date','subscriber_id','workspace_id']
) }}

    select distinct
        SRC_FILENAME,
        data:api::VARCHAR as api,
        data:channel::VARCHAR as channel,
        data:errorMessage::VARCHAR as "ERROR_MESSAGE",
        data:legalEntityName::VARCHAR as legal_entity_name,
        data:obCode::VARCHAR as ob_code,
        data:pms::VARCHAR as pms,
        data:product::VARCHAR as product,
        data:requestBody::VARCHAR as request_body,
        data:requestQryString::VARCHAR as request_qry_string,
        REPLACE(data:requestTimestamp, 'T', ' ')::TIMESTAMP_NTZ  AS request_timestamp, 
        CONVERT_TIMEZONE('UTC','Australia/Sydney',REPLACE(data:requestTimestamp, 'T', ' ')::TIMESTAMP_NTZ) AS request_timestamp_aest, 
        data:requestUrl::VARCHAR as request_url,
        data:responseBody::VARCHAR as response_body,
        data:responseHeaders::VARCHAR as response_headers,
        data:responseStatus::VARCHAR as response_status,
        data:subscriberId::VARCHAR as subscriber_id,
        data:subscriberType::VARCHAR as subscriber_type,
        data:username::VARCHAR as username,
        data:uuid::VARCHAR as uuid,
        data:workspaceId::VARCHAR as workspace_id,
        data:clientName::VARCHAR as client_name,
        inserted_at as src_inserted_at,
        {{ var('inserted_at') }} as inserted_at
    from {{ ref('api_report_logs') }}

    {% if is_incremental() %}
        where inserted_at > (select coalesce(max(src_inserted_at), '1900-01-01 00:00:00') from {{ this }}) 
    {% endif %}
