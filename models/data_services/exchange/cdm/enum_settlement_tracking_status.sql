{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/SettlementTrackingStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, step1, step2, is_default
    FROM (VALUES
        ('LODGEMENT_VERIFICATION_SENT_SUCCESS', 'Lodgement Verification Sent: Success', 2, 5, FALSE),
        ('LODGEMENT_VERIFICATION_SENT_FAIL', 'Lodgement Verification Sent: Fail', 2, 15, FALSE),
        ('LODGEMENT_VERIFICATION_RESPONSE_SUCCESS', 'Lodgement Verification Response: Success', 4, 5, FALSE),
        ('LODGEMENT_VERIFICATION_RESPONSE_TIMEOUT', 'Lodgement Verification Response: Timeout', 4, 10, FALSE),
        ('LODGEMENT_VERIFICATION_RESPONSE_FAIL', 'Lodgement Verification Response: Fail', 4, 15, FALSE),
        ('STAMP_DUTY_VERIFICATION_SENT_SUCCESS', 'Stamp Duty Verification Sent: Success', 5, 5, FALSE),
        ('STAMP_DUTY_VERIFICATION_SENT_FAIL', 'Stamp Duty Verification Sent: Fail', 5, 15, FALSE),
        ('STAMP_DUTY_VERIFICATION_RESPONSE_SUCCESS', 'Stamp Duty Verification Response: Success', 7, 5, FALSE),
        ('STAMP_DUTY_VERIFICATION_RESPONSE_TIMEOUT', 'Stamp Duty Verification Response: Timeout', 7, 10, FALSE),
        ('STAMP_DUTY_VERIFICATION_RESPONSE_FAIL', 'Stamp Duty Verification Response: Fail', 7, 15, FALSE),
        ('EXECUTION_INTIATION_SUCCESS', 'Execution Initiation: Success', 10, 5, FALSE),
        ('SOURCE_FILE_GENERATED_SUCCESS', 'Source File Generated: Success', 15, 5, FALSE),
        ('SOURCE_FILE_GENERATED_FAIL', 'Source File Generated: Fail', 15, 15, FALSE),
        ('SOURCE_FILE_SENT_SUCCESS', 'Source File Sent: Success', 17, 5, FALSE),
        ('SOURCE_FILE_SENT_FAIL', 'Source File Sent: Fail', 17, 15, FALSE),
        ('SOURCE_PAYMENT_RESPONSE_SUCCESS', 'Source Payment Response: Success', 20, 5, FALSE),
        ('SOURCE_PAYMENT_RESPONSE_TIMEOUT', 'Source Payment Response: Timeout', 20, 10, FALSE),
        ('SOURCE_PAYMENT_RESPONSE_FAIL', 'Source Payment Response: Fail', 20, 15, FALSE),
        ('SOURCE_FILE_SENT_SUCCESS_RETRY', 'Source File Sent: Success - Retry', 22, 5, FALSE),
        ('SOURCE_FILE_SENT_MANUAL', 'Source File Sent: Manual', 24, 5, FALSE),
        ('RITS_RESERVATION_REQUEST_GENERATED_SUCCESS', 'RITS Reservation Request Generated: Success', 25, 5, FALSE),
        ('RITS_RESERVATION_REQUEST_GENERATED_FAIL', 'RITS Reservation Request Generated: Fail', 25, 15, FALSE),
        ('RITS_RESERVATION_REQUEST_SENT_SUCCESS', 'RITS Reservation Request Sent: Success', 27, 5, FALSE),
        ('RITS_RESERVATION_REQUEST_SENT_FAIL', 'RITS Reservation Request Sent: Fail', 27, 15, FALSE),
        ('RITS_RESERVATION_RESPONSE_SUCCESS', 'RITS Reservation Response: Success', 28, 5, FALSE),
        ('RITS_RESERVATION_RESPONSE_TIMEOUT', 'RITS Reservation Response: Timeout', 28, 10, FALSE),
        ('RITS_RESERVATION_RESPONSE_FAIL', 'RITS Reservation Response: Fail', 28, 15, FALSE),
        ('RITS_RESERVATION_REQUEST_SENT_SUCCESS_RETRY', 'RITS Reservation Request Sent: Success - Retry', 29, 5, FALSE),
        ('RITS_RESERVATION_REQUEST_SENT_MANUAL', 'RITS Reservation Request Sent: Manual', 30, 5, FALSE),
        ('STAMP_DUTY_COMMITMENT_SENT_SUCCESS', 'Stamp Duty Commitment Sent: Success', 32, 5, FALSE),
        ('STAMP_DUTY_COMMITMENT_SENT_FAIL', 'Stamp Duty Commitment Sent: Fail', 32, 5, FALSE),
        ('STAMP_DUTY_COMMITMENT_SENT_PROCEED', 'Stamp Duty Commitment Sent: Proceed', 33, 5, FALSE),
        ('STAMP_DUTY_COMMITMENT_RESPONSE_SUCCESS', 'Stamp Duty Commitment Response: Success', 35, 5, FALSE),
        ('STAMP_DUTY_COMMITMENT_RESPONSE_TIMEOUT', 'Stamp Duty Commitment Response: Timeout', 35, 10, FALSE),
        ('STAMP_DUTY_COMMITMENT_RESPONSE_FAIL', 'Stamp Duty Commitment Response: Fail', 35, 15, FALSE),
        ('STAMP_DUTY_COMMITMENT_RESPONSE_TECH_ERROR', 'Stamp Duty Commitment Response: Tech Error', 36, 15, FALSE),
        ('STAMP_DUTY_COMMITMENT_RESPONSE_PROCEED', 'Stamp Duty Commmitment Response: Proceed', 36, 15, FALSE),
        ('LODGEMENT_REQUEST_SENT_SUCCESS', 'Lodgement Request Sent: Success', 37, 5, FALSE),
        ('LODGEMENT_REQUEST_SENT_FAIL', 'Lodgement Request Sent: Fail', 37, 15, FALSE),
        ('LODGEMENT_REQUEST_SENT_PROCEED', 'Lodgement Request Sent: Proceed', 37, 20, FALSE),
        ('LODGEMENT_A6_RECEIVED_SUCCESS', 'Lodgement A6 Response: Success', 40, 5, FALSE),
        ('LODGEMENT_A6_RECEIVED_TIMEOUT', 'Lodgement A6 Response: Timeout', 40, 10, FALSE),
        ('LODGEMENT_A6_RECEIVED_FAIL', 'Lodgement A6 Response: Fail', 40, 15, FALSE),
        ('LODGEMENT_A6_RECEIVED_PROCEED', 'Lodgement A6 Response: Proceed', 40, 20, FALSE),
        ('LODGEMENT_A6_RESPONSE_SUCCESS', 'Lodgement A6 Response: Success', 45, 5, FALSE),
        ('LODGEMENT_A6_RESPONSE_TIMEOUT', 'Lodgement A6 Response: Timeout', 45, 10, FALSE),
        ('LODGEMENT_A6_RESPONSE_FAIL', 'Lodgement A6 Response: Fail', 45, 15, FALSE),
        ('LODGEMENT_A6_RESPONSE_PROCEED', 'Lodgement A6 Response: Proceed', 45, 20, FALSE),
        ('LODGEMENT_A9_RESPONSE_SUCCESS', 'Lodgement A9 Response: Success', 50, 5, FALSE),
        ('LODGEMENT_A9_RESPONSE_TIMEOUT', 'Lodgement A9 Response: Timeout', 50, 10, FALSE),
        ('LODGEMENT_A9_RESPONSE_FAIL', 'Lodgement A9 Response: Fail (Not Accepted)', 50, 15, FALSE),
        ('LODGEMENT_A9_RESPONSE_PROCEED', 'Lodgement A9 Response: Proceed', 50, 20, FALSE),
        ('RITS_SETTLEMENT_REQUEST_GENERATED_SUCCESS', 'RITS Settlement Request Generated: Success', 55, 5, FALSE),
        ('RITS_SETTLEMENT_REQUEST_GENERATED_FAIL', 'RITS Settlement Request Generated: Fail', 55, 15, FALSE),
        ('RITS_SETTLEMENT_REQUEST_SENT_SUCCESS', 'RITS Settlement Request Sent: Success', 57, 5, FALSE),
        ('RITS_SETTLEMENT_REQUEST_SENT_FAIL', 'RITS Settlement Request Sent: Fail', 57, 15, FALSE),
        ('RITS_SETTLEMENT_RESPONSE_SUCCESS', 'RITS Settlement Response: Success', 60, 5, FALSE),
        ('RITS_SETTLEMENT_RESPONSE_TIMEOUT', 'RITS Settlement Response: Timeout', 60, 10, FALSE),
        ('RITS_SETTLEMENT_RESPONSE_FAIL', 'RITS Settlement Response: Fail', 60, 15, FALSE),
        ('RITS_SETTLEMENT_REQUEST_SENT_MANUAL', 'RITS Settlement Request Sent: Manual', 65, 5, FALSE),
        ('DISBURSEMENT_FILE_GENERATED_SUCCESS', 'Disbursement File Generated: Success', 70, 5, FALSE),
        ('DISBURSEMENT_FILE_GENERATED_FAIL', 'Disbursement File Generated: Fail', 70, 15, FALSE),
        ('DISBURSEMENT_FILE_SENT_SUCCESS', 'Disbursement File Sent: Success', 72, 5, FALSE),
        ('DISBURSEMENT_FILE_SENT_FAIL', 'Disbursement File Sent: Fail', 72, 15, FALSE),
        ('DISBURSEMENT_PAYMENT_RESPONSE_TIMEOUT', 'Disbursement Payment Response: Timeout', 75, 5, FALSE),
        ('DISBURSEMENT_PAYMENT_RESPONSE_SUCCESS', 'Disbursement Payment Response: Success', 75, 10, FALSE),
        ('DISBURSEMENT_PAYMENT_RESPONSE_FAIL', 'Disbursement Payment Response: Fail', 75, 15, FALSE),
        ('DISBURSING_PAYMENT_RESPONSE_FAIL', 'Disbursement Payment Response: Fail', 75, 15, FALSE), {#- @Deprecated #}
        ('INTERIM_DISBURSEMENT_FILE_GENERATED_BLANK', 'Interim Disbursement File Generated: (blank)', 76, 5, FALSE),
        ('DISBURSEMENT_FILE_SENT_MANUAL', 'Disbursement File Sent: Manual', 77, 5, FALSE),
        ('DISBURSEMENT_PAYMENT_RESPONSE_MANUAL', 'Disbursement Payment Response: Manual', 80, 5, FALSE),
        ('INTERIM_DISBURSEMENT_FILE_GENERATED_FAIL', 'Interim Disbursement File Generated: Fail', 85, 15, FALSE),
        ('INTERIM_DISBURSEMENT_FILE_SENT_SUCCESS', 'Interim Disbursement File Sent: Success', 87, 5, FALSE),
        ('INTERIM_DISBURSEMENT_FILE_SENT_FAIL', 'Interim Disbursement File Sent: Fail', 87, 15, FALSE),
        ('INTERIM_DISBURSEMENT_PAYMENT_RESPONSE_SUCCESS', 'Interim Disbursement Payment Response: Success', 90, 5, FALSE),
        ('INTERIM_DISBURSEMENT_PAYMENT_RESPONSE_TIMEOUT', 'Interim Disbursement Payment Response: Timeout', 90, 10, FALSE),
        ('INTERIM_DISBURSEMENT_PAYMENT_RESPONSE_FAIL', 'Interim Disbursement Payment Response: Fail', 90, 15, FALSE),
        ('INTERIM_DISBURSEMENT_FILE_SENT_MANUAL', 'Interim Disbursement File Sent: Manual', 92, 5, FALSE),
        ('INTERIM_DISBURSEMENT_PAYMENT_RESPONSE_MANUAL', 'Interim Disbursement Payment Response: Manual', 93, 5, FALSE),
        ('BPAY_FILE_SENT_SUCCESS', 'BPay File Sent: Success', 95, 5, FALSE),
        ('BPAY_FILE_SENT_FAIL', 'BPay File Sent: Fail', 95, 15, FALSE),
        ('BPAY_PAYMENT_RESPONSE_SUCCESS', 'BPay Payment Response: Success', 97, 5, FALSE),
        ('BPAY_PAYMENT_RESPONSE_TIMEOUT', 'BPay Payment Response: Timeout', 97, 10, FALSE),
        ('BPAY_PAYMENT_RESPONSE_FAIL', 'BPay Payment Response: Fail', 97, 15, FALSE),
        ('BPAY_FILE_SENT_MANUAL', 'BPay File Sent: Manual', 100, 5, FALSE),
        ('NON_INTEGRATED_PAYMENT_FILE_SENT_SUCCESS', 'Non Integrated Payment File Sent: Success', 102, 5, FALSE),
        ('NON_INTEGRATED_PAYMENT_FILE_SENT_FAIL', 'Non Integrated Payment File Sent: Fail', 102, 15, FALSE),
        ('NON_INTEGRATED_PAYMENT_RESPONSE_SUCCESS', 'Non Integrated Payment Response: Success', 105, 5, FALSE),
        ('NON_INTEGRATED_PAYMENT_RESPONSE_TIMEOUT', 'Non Integrated Payment Response: Timeout', 105, 10, FALSE),
        ('NON_INTEGRATED_PAYMENT_RESPONSE_FAIL', 'Non Integrated Payment Response: Fail', 105, 15, FALSE),
        ('NON_INTEGRATED_PAYMENT_FILE_SENT_MANUAL', 'Non Integrated Payment File Sent: Manual', 107, 5, FALSE),
        ('THIRD_PARTY_FILE_GENERATED_SUCCESS', 'Third Party File Generated: Success', 110, 5, FALSE),
        ('THIRD_PARTY_FILE_GENERATED_FAIL', 'Third Party File Generated: Fail', 110, 15, FALSE),
        ('THIRD_PARTY_FILE_SENT_SUCCESS', 'Third Party File Sent: Success', 112, 5, FALSE),
        ('THIRD_PARTY_FILE_SENT_FAIL', 'Third Party File Sent: Fail', 112, 15, FALSE),
        ('THIRD_PARTY_PAYMENT_RESPONSE_SUCCESS', 'Third Party Payment Response: Success', 115, 5, FALSE),
        ('THIRD_PARTY_PAYMENT_RESPONSE_TIMEOUT', 'Third Party Payment Response: Timeout', 115, 10, FALSE),
        ('THIRD_PARTY_PAYMENT_RESPONSE_FAIL', 'Third Party Payment Response: Fail', 115, 15, FALSE),
        ('RITS_RESERVATION_RECALL_FILE_GENERATED_SUCCESS', 'RITS Reservation Recall File Generated: Success', 120, 5, FALSE),
        ('RITS_RESERVATION_RECALL_FILE_GENERATED_FAIL', 'RITS Reservation Recall File Generated: Fail', 120, 15, FALSE),
        ('RITS_RESERVATION_RECALL_FILE_SENT_SUCCESS', 'RITS Reservation Recall File Sent: Success', 123, 5, FALSE),
        ('RITS_RESERVATION_RECALL_FILE_SENT_FAIL', 'RITS Reservation Recall File Sent: Fail', 123, 15, FALSE),
        ('RITS_RESERVATION_RECALL_RESPONSE_SUCCESS', 'RITS Reservation Recall Response: Success', 125, 5, FALSE),
        ('RITS_RESERVATION_RECALL_RESPONSE_FAIL', 'RITS Reservation Recall Response: Fail', 125, 15, FALSE),
        ('RESERVATION_RECALL_RESPONSE_SUCCESS', 'Reservation Recall Response: Success', 130, 5, FALSE),
        ('RESERVATION_RECALL_RESPONSE_TIMEOUT', 'Reservation Recall Response: Timeout', 130, 10, FALSE),
        ('RESERVATION_RECALL_RESPONSE_FAIL', 'Reservation Recall Response: Fail', 130, 15, FALSE),
        ('RESERVATION_UNWOUND', 'Reservation Unwound', 135, 5, FALSE),
        ('ROLLBACK_FILE_GENERATED_FAIL', 'Rollback File Generated: Fail', 140, 1, FALSE),
        ('ROLLBACK_FILE_GENERATED_SUCCESS', 'Rollback File Generated: Success', 140, 3, FALSE),
        ('ROLLBACK_FILE_SENT_SUCCESS', 'Rollback File Sent: Success', 140, 5, FALSE),
        ('ROLLBACK_FILE_SENT_FAIL', 'Rollback File Sent: Fail', 140, 15, FALSE),
        ('ROLLBACK_PAYMENT_RESPONSE_SUCCESS', 'Rollback Payment Response: Success', 142, 5, FALSE),
        ('ROLLBACK_PAYMENT_RESPONSE_TIMEOUT', 'Rollback Payment Response: Timeout', 142, 10, FALSE),
        ('ROLLBACK_PAYMENT_RESPONSE_FAIL', 'Rollback Payment Response: Fail', 142, 15, FALSE),
        ('ROLLBACK_FILE_SENT_MANUAL', 'Rollback File Sent: Manual', 145, 5, FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 'Unknown Settlement Tracking Status', NULL, NULL, TRUE)
    ) v(enum_name, enum_value, step1, step2, is_default)
)
SELECT
    '2026-03-12 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,
    step1,
    step2,

    (step1 * 1000 + step2) AS heirarchy,
    (enum_value ILIKE '%success%') AS is_success,
    (enum_value ILIKE ANY ('%rits%fail%', '%lodgement%fail%', '%fail%rits%', '%fail%lodgement%')) AS is_failed,
    (enum_value ILIKE ANY ('%rits%timeout%', '%lodgement%timeout%', '%timeout%rits%', '%timeout%lodgement%')) AS is_timeout,
    CASE WHEN enum_name IN (
        'RITS_SETTLEMENT_RESPONSE_SUCCESS', 'DISBURSEMENT_FILE_SENT_SUCCESS', 'DISBURSEMENT_PAYMENT_RESPONSE_SUCCESS',
        'THIRD_PARTY_FILE_SENT_SUCCESS', 'THIRD_PARTY_PAYMENT_RESPONSE_SUCCESS'
    )
        THEN TRUE ELSE FALSE END AS is_settled, {#- Get all status that indicate settlement is past RITS settlement. #}
    CASE WHEN enum_name IN (
        'RITS_RESERVATION_REQUEST_SENT_MANUAL', 'RITS_RESERVATION_REQUEST_SENT_SUCCESS', 'RITS_RESERVATION_REQUEST_SENT_FAIL',
        'RITS_RESERVATION_RESPONSE_SUCCESS', 'RITS_RESERVATION_RESPONSE_FAIL', 'RITS_SETTLEMENT_REQUEST_SENT_MANUAL',
        'RITS_SETTLEMENT_REQUEST_SENT_SUCCESS', 'RITS_SETTLEMENT_REQUEST_SENT_FAIL', 'RITS_SETTLEMENT_RESPONSE_SUCCESS',
        'RITS_SETTLEMENT_RESPONSE_FAIL', 'RITS_SETTLEMENT_RESPONSE_TIMEOUT'
    )
        THEN TRUE ELSE FALSE END AS is_rits_update, {#- Statuses for Rits Update. #}
    CASE WHEN enum_name IN (
        'SOURCE_FILE_SENT_FAIL', 'SOURCE_PAYMENT_RESPONSE_FAIL', 'RITS_RESERVATION_REQUEST_SENT_FAIL',
        'RITS_RESERVATION_RESPONSE_FAIL', 'STAMP_DUTY_COMMITMENT_SENT_FAIL', 'STAMP_DUTY_COMMITMENT_RESPONSE_TIMEOUT',
        'RITS_SETTLEMENT_RESPONSE_FAIL'
    )
        THEN TRUE ELSE FALSE END AS is_in_cutoff_status,
    CASE WHEN enum_name IN ('RITS_SETTLEMENT_REQUEST_SENT_FAIL', 'RITS_SETTLEMENT_REQUEST_GENERATED_FAIL')
        THEN TRUE ELSE FALSE END AS is_rits_settlement_tech_error
FROM enum