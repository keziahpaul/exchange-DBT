with source as (

    select * from {{ ref('pxa_settlement_schedules') }}

),

renamed as (

    select
        settlement_schedule_id,
        version,
        amount,
        funds_available,
        account_id,
        settlement_id,
        settlement_category_id,
        participant_id,
        is_authorized,
        clearing_account_id,
        payment_tracking_id,
        transaction_id,
        underlying_account_id,
        payment_method,
        bpay_details_id,
        transaction_description,
        schedule_status,
        interim_account_id,
        linked_settlement_id,
        authorisation_status,
        category_description,
        prcd_sttlmt_if_trail_ws_failed,
        third_party_account_id,
        verified_by,
        verified_date,
        auto_balance_id,
        associated_subscriber,
        verification_status,
        is_for_dual_verification,
        verification_count,
        client_name,
        authorisation_definition_id,
        transaction_date,
        source_reference,
        routed_to,
        pxa_source_account,
        panel_master,
        amount_modified_date,
        associated_subscriber_role,
        assigned_to,
        locked_flag,
        hash_code,
        salt,
        send_request_count,
        is_auto_calculated,
        auto_calculation_status,
        last_updated,
        bpay_validation_flag,
        interop_reference_id,
        required_to_sign,
        signed_at,
        interop_fi_name,
        --beneficiary_status,
       --trade_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
