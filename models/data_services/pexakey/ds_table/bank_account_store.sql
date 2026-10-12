{{
    config(
        materialized='table',
        unique_key='task_id',
        full_refresh=true
    )
}}

WITH normalized_data AS (
    SELECT
        --Primary ID and Filter Column
        NVL(data:Item.Data.M.taskModel.M.taskId.S::VARCHAR,REGEXP_REPLACE(data:Item.id.S::VARCHAR, '^TaskLogicalTable-', '')) AS task_id,
        data:Item.id.S::VARCHAR AS id,
        data:Item.eventName::VARCHAR AS event_name,
        -- Task Model Fields from variant column
        data:Item.Data.M.taskModel.M.subscriberId.S::VARCHAR AS subscriber_id,
        data:Item.Data.M.taskModel.M.taskStatus.S::VARCHAR AS task_status,
        data:Item.Data.M.taskModel.M.role.S::VARCHAR AS role,
        data:Item.Data.M.taskModel.M.workspaceInternalId.N::NUMBER AS workspace_internal_id,
        data:Item.Data.M.taskModel.M.partyId.S::VARCHAR AS party_id,
        data:Item.Data.M.taskModel.M.correlationToken.S::VARCHAR AS correlation_token,
        data:Item.Data.M.taskModel.M.email.S::VARCHAR AS email,
        data:Item.Data.M.taskModel.M.viewed.N::NUMBER AS viewed,
        data:Item.Data.M.taskModel.M.taskAction.S::VARCHAR AS task_action,

        -- Bank Account Details directly from variant
        PARSE_JSON(Data:Item.Data.M.taskModel.M.accountDetails.S):bankAccountName::VARCHAR AS bank_account_name,
        PARSE_JSON(Data:Item.Data.M.taskModel.M.accountDetails.S):bankAccountNumber::VARCHAR AS bank_account_number,
        PARSE_JSON(Data:Item.Data.M.taskModel.M.accountDetails.S):bankAccountBSB::VARCHAR AS bank_account_bsb,
        PARSE_JSON(Data:Item.Data.M.taskModel.M.accountDetails.S):bankAccountReference::VARCHAR AS bank_account_reference,
        PARSE_JSON(Data:Item.Data.M.taskModel.M.accountDetails.S):bankMnemonic::VARCHAR AS bank_mnemonic,
        PARSE_JSON(Data:Item.Data.M.taskModel.M.accountDetails.S):amount::NUMBER AS amount,
        src_file_last_modified_date AS src_load_ts,

        -- Event Type mapping
        CASE data:Item.Data.M.taskModel.M.eventType.S::VARCHAR
            WHEN '01' THEN 'Vendor Surplus Account'
            WHEN '02' THEN 'Trust Account'
            WHEN '03' THEN 'PEXA Source Account'
            WHEN '04' THEN 'Purchaser Surplus Account'
            ELSE data:Item.Data.M.taskModel.M.eventType.S::VARCHAR
        END AS event_type,

        -- Timezone conversion for dates
        CONVERT_TIMEZONE('UTC',
            'Australia/Melbourne',
            TRY_TO_TIMESTAMP(data:Item.Data.M.taskModel.M.dateCreated.S::STRING)
        )::TIMESTAMP_TZ AS date_created,

        CONVERT_TIMEZONE('UTC',
            'Australia/Melbourne',
            TRY_TO_TIMESTAMP(data:Item.Data.M.taskModel.M.dateUpdated.S::STRING)
        )::TIMESTAMP_TZ AS date_updated
    FROM {{ ref('vw_bank_account_store' ) }}
    WHERE id LIKE 'TaskLogicalTable%'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY task_id ORDER BY nvl(date_updated,date_created) desc nulls first,src_load_ts DESC) = 1
)

SELECT
    subscriber_id,
    task_status,
    event_type,
    date_created,
    role,
    workspace_internal_id,
    task_id,
    party_id,
    date_updated,
    correlation_token,
    email,
    viewed,
    task_action,
    bank_account_name,
    bank_account_number,
    bank_account_bsb,
    bank_account_reference,
    bank_mnemonic,
    amount,
    src_load_ts,
    {{ var('inserted_at') }} AS inserted_at
FROM normalized_data
where nvl(event_name,'UNKNOWN')!='REMOVE'
