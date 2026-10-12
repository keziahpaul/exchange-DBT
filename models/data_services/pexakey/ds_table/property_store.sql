{{
    config(
        materialized='table',
        unique_key='tracking_id',
        full_refresh=true
    )
}}

WITH normalized_data AS (
    SELECT
        --Primary ID and Filter Column
        nvl(data:Item.Data.M.model.M.trackingId.S::VARCHAR,REGEXP_REPLACE(data:Item.id.S::VARCHAR, '^PropertyDetailsLogicalTable-', '')) AS tracking_id,
        data:Item.id.S::VARCHAR AS id,
        data:Item.eventName::VARCHAR AS event_name,
        -- Base Fields
        data:Item.Data.M.model.M.subscriberId.S::VARCHAR AS subscriber_id,
        data:Item.Data.M.model.M.trackingStatus.S::VARCHAR AS tracking_status,
        PARSE_JSON(data:Item.Data.M.model.M.propertyDetails.S):address:structuredAddress:addressLine::VARCHAR AS address_line,

        --Audit Fields
        src_file_last_modified_date AS src_load_ts,
        CONVERT_TIMEZONE('UTC',
            'Australia/Melbourne',
            TRY_TO_TIMESTAMP(data:Item.Data.M.model.M.dateCreated.S::VARCHAR)
        )::TIMESTAMP_TZ AS date_created,
        CONVERT_TIMEZONE('UTC',
            'Australia/Melbourne',
            TRY_TO_TIMESTAMP(data:Item.Data.M.model.M.dateUpdated.S::VARCHAR)
        )::TIMESTAMP_TZ AS date_updated

    FROM {{ ref('vw_property_store' ) }}
    WHERE id LIKE 'PropertyDetailsLogicalTable%'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY tracking_id ORDER BY nvl(date_updated,date_created) desc nulls first, src_load_ts DESC) = 1
)

SELECT
    subscriber_id,
    tracking_id,
    tracking_status,
    address_line,
    date_updated,
    src_load_ts,
    {{ var('inserted_at') }} AS inserted_at
FROM normalized_data
where nvl(event_name,'UNKNOWN')!='REMOVE'
