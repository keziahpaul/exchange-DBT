with source as (

    select * from {{ ref('pxa_documents') }}

),

renamed as (

    select
        document_id,
        status,
        version,
        lodgement_id,
        document_type_id,
        dealing_number,
        last_updated_date,
        last_updated_by,
        order_of_lodgement,
        fee,
        lodgement_verification_status,
        lodgement_verification_date,
        settlement_id,
        created_date,
        created_by,
        created_by_role_id,
        document_definition,
        document_status_advice,
        status_advice_time,
        setofoperativewords,
        subscribersetofoperativewords,
        parent_document,
        created_by_username,
        created_by_susbscriber_id,
        created_by_system_user,
        last_updated_by_username,
        last_updated_by_susbscriber_id,
        last_updated_by_system_user,
        attachment_needed,
        has_joint_with_no_survivorship,
        stamp_duty_id,
        document_summary_text,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'


)

select * from renamed
