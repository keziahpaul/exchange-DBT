

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
    inserted_at
FROM {{ ref('bank_account_store' ) }}
