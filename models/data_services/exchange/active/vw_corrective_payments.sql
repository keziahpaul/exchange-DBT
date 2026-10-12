with source as (

    select * from {{ ref('pxa_corrective_payments') }}

),

renamed as (

    select
        corrective_payment_id,
        transaction_id,
        corrective_id,
        settlement_schedule_id,
        subscriber_id,
        workspace_id,
        status,
        settlement_date,
        corrective_home_id,
        amount,
        payment_method,
        account_type,
        account_bsb,
        account_number,
        account_holder,
        new_payment_method,
        new_account_bsb,
        new_account_number,
        new_account_holder,
        created_user_name,
        created_user_id,
        created_date,
        saved_user_name,
        saved_user_id,
        saved_date,
        submitted_user_name,
        submitted_user_id,
        submitted_date,
        accepted_user_name,
        accepted_user_id,
        accepted_date,
        processing_user_name,
        processing_user_id,
        processing_date,
        processed_user_name,
        processed_user_id,
        processed_date,
        participant_id,
        transaction_description,
        new_transaction_description,
        common_signature_id,
        subscriber_reference,
        ss_last_updated_by,
        cancelled_user_name,
        cancelled_user_id,
        cancelled_date,
        version,
        transaction_response,
        batch_id,
        corrective_bpay_flag,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
