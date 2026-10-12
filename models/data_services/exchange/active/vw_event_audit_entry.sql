with source as (

    select * from {{ ref('pxa_event_audit_entry') }}

),

renamed as (

    select
        event_audit_entry_id,
        business_event_id,
        created_date,
        message,
        event_audit_type_id,
        new_values,
        old_values,
        s3_old_values_ref,
        s3_new_values_ref,
        inserted_at


    from source

)


select * from renamed