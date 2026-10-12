{{
    config(
        materialized='table',
        unique_key='tracking_Id',
        full_refresh=true
    )
}}

WITH normalized_data AS (
    SELECT
        --Primary ID and Filter Column
        data:Item.id.S::VARCHAR AS id,
        data:Item.eventName::VARCHAR AS event_name,
        --propertySettlementsModel fields
        data:Item.Data.M.propertySettlementsModel.M.mobile.S::VARCHAR as mobile,
        CONVERT_TIMEZONE('UTC','Australia/Melbourne', TRY_TO_TIMESTAMP(data:Item.Data.M.propertySettlementsModel.M.dateCreated.S::VARCHAR))::TIMESTAMP_TZ as date_created,
        data:Item.Data.M.propertySettlementsModel.M.partyId.S::VARCHAR as party_Id,
        data:Item.Data.M.propertySettlementsModel.M.trackingId.S::VARCHAR as tracking_Id,
        data:Item.Data.M.propertySettlementsModel.M.workspaceInternalId.N::VARCHAR as workspace_Internal_Id,
        data:Item.Data.M.propertySettlementsModel.M.correlationToken.S::VARCHAR as correlation_Token,
        data:Item.Data.M.propertySettlementsModel.M.email.S::VARCHAR as email,
        --propertySettlementDetails fields
        PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):role::VARCHAR as role,
        TO_TIMESTAMP_TZ(PARSE_JSON(PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):settlement_details):settlement_date::VARCHAR) as settlement_date,
        PARSE_JSON(PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):subscriber_details):subscriber_name::VARCHAR as subscriber_name,
        PARSE_JSON(PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):property_details):property_classification::VARCHAR as property_classification,
        --property_details address fields
        PARSE_JSON(PARSE_JSON(PARSE_JSON(PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):property_details):address):structured_address):suburb::VARCHAR as suburb,
        PARSE_JSON(PARSE_JSON(PARSE_JSON(PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):property_details):address):structured_address):state::VARCHAR as state,
        PARSE_JSON(PARSE_JSON(PARSE_JSON(PARSE_JSON(data:Item.Data.M.propertySettlementsModel.M.propertySettlementDetails.S):property_details):address):structured_address):postcode::VARCHAR as postcode,
        src_file_last_modified_date AS src_load_ts,
        CONVERT_TIMEZONE('UTC','Australia/Melbourne', TRY_TO_TIMESTAMP(data:Item.Data.M.propertySettlementsModel.M.dateUpdated.S::VARCHAR))::TIMESTAMP_TZ as date_updated

    FROM {{ ref('vw_property_settlement' ) }}
    WHERE id LIKE 'PropertySettlementLogicalTable%'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY tracking_id ORDER BY nvl(date_updated,date_created) desc nulls first,src_load_ts DESC) = 1

    
)

select
    event_name,
    mobile,
    date_created,
    party_Id,
    tracking_Id,
    workspace_Internal_Id,
    date_updated,
    correlation_Token,
    email,
    role,
    settlement_date,
    subscriber_name,
    property_classification,
    suburb,
    state,
    postcode,
    src_load_ts,
    {{ var('inserted_at') }} AS inserted_at
FROM normalized_data
WHERE nvl(event_name,'UNKNOWN')!='REMOVE'