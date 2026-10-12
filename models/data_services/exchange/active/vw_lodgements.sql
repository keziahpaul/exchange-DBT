with source as (

    select * from {{ ref('pxa_lodgements') }}

),

renamed as (

    select
        lodgement_id,
        version,
        date1,
        status,
        workspace_id,
        verification_request_time,
        verification_response_time,
        transaction_type,
        verification_request_xml,
        settlement_id,
        workspace_lock_date,
        lodgement_request_time,
        lodgement_response_time,
        status_advice_time,
        notification_ack_time,
        notification_status_time,
        billing_event_flag,
        tac_flag,
        express_refi_flag,
        express_refi_subscriber,
        retry_flag,
        day_prior_lv_timestamp,
        verification_ack_response,
        verification_request_xml_ref,
        lodgement_id_external,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed