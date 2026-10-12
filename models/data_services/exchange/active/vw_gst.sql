with 

source as (

    select * from {{ ref('pxa_gst') }}

),

renamed as (

    select
        id,
        version,
        workspace_id,
        transfer_id,
        form_type,
        gst_data,
        document_status,
        last_modified_by,
        last_modified_date,
        verification_status,
        request_time,
        response_time,
        verification_response_details,
        gst_data_ref,
        verification_response_det_ref,
        lodgement_response_time,
        lodgement_request_time,
        settlement_schedule_id,
        participant_id,
        gst_withholding_amount,
        payment_reference,
        lodgement_reference,
        gst_retry,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
