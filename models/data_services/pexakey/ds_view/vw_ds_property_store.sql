
SELECT
    subscriber_id,
    tracking_id,
    tracking_status,
    address_line,
    date_updated,
    src_load_ts,
    inserted_at
FROM {{ ref('property_store' ) }}
