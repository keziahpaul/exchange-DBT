with source as (

    select * from {{ ref('pxa_stamp_duty') }}

),

renamed as (

    select
        stamp_duty_id,
        osr_transaction_id,
        duty_assessed_amount,
        duty_payable_amount,
        paid_in_pexa,
        verification_request_time,
        verification_response_time,
        retry_count,
        commitment_request_time,
        commitment_response_time,
        stamp_duty_verification_status,
        payment_status,
        osr_status_advice,
        compliance_indicator,
        stamp_duty_compliance,
        settlement_schedule,
        commitment_to_pay,
        evidence_details,
        document_id,
        assessment_number,
        osr_client_number,
        exemption,
        uti,
        duty_assessment_date,
        payment_method,
        exemption_reason,
        responsible_user,
        dutiable_value,
        previous_status,
        previous_verification_response,
        penalty_tax,
        foreign_ownership_surcharge,
        earliest_settlement_date,
        osr_case_status,
        send_old_sdv,
        is_complex_assessment,
        latest_settlement_date,
        evidence_details_ref,
        nominal_duty_reason,
        manual_verification,
        duty_concession_reason,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed