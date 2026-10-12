{{
    config(
        materialized='table',
        unique_key=['username','mobile'],
        full_refresh=true
    )
}}

WITH normalized_data AS (
    SELECT
        --Primary ID and Filter Column
        data:Item.id.S::VARCHAR AS id,
        nvl(data:Item.user.M.model.M.username.S::VARCHAR,REGEXP_REPLACE(data:Item.id.S::VARCHAR, '^[^-]*-|-[^-]*$')) AS username,
        nvl(data:Item.user.M.model.M.mobile.S::VARCHAR, REGEXP_REPLACE(data:Item.id.S::VARCHAR,'^([^-]*-){2}')) AS mobile,
        data:Item.eventName::VARCHAR AS event_name,
        -- Extract other fields
        data:Item.user.M.model.M.givenName.S::VARCHAR AS given_name,
        data:Item.user.M.model.M.email.S::VARCHAR AS email,
        data:Item.user.M.model.M.id.S::VARCHAR AS user_id,
        data:Item.user.M.model.M.registrationStatus.S::VARCHAR AS registration_status,
        data:Item.user.M.model.M.surname.S::VARCHAR AS surname,
        data:Item.user.M.model.M.organisationName.S::VARCHAR AS organisation_name,

        -- Convert UTC timestamps to local time
        src_file_last_modified_date AS src_load_ts,
        CONVERT_TIMEZONE('UTC',
            'Australia/Melbourne',
            TRY_TO_TIMESTAMP(data:Item.user.M.model.M.dateCreated.S::VARCHAR)
        )::TIMESTAMP_TZ AS date_created,

        CONVERT_TIMEZONE('UTC',
            'Australia/Melbourne',
            TRY_TO_TIMESTAMP(data:Item.user.M.model.M.dateUpdated.S::VARCHAR)
        )::TIMESTAMP_TZ AS date_updated

    FROM {{ ref('vw_web_app_registration' ) }}
    WHERE id LIKE 'UserLogicalTable%'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY username, mobile ORDER BY nvl(date_updated,date_created) desc nulls first,src_load_ts DESC) = 1
)

SELECT
    date_created,
    date_updated,
    email,
    given_name,
    user_id,
    mobile,
    registration_status,
    surname,
    username,
    organisation_name,
    src_load_ts,
    {{ var('inserted_at') }} AS inserted_at
FROM normalized_data
where nvl(event_name,'UNKNOWN')!='REMOVE'