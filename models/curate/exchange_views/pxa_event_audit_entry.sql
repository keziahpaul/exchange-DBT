{{ config (
    materialized="view"
)
}}

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
        extraction_start_ts,
        inserted_at 
    from {{ ref('stg_pxa_event_audit_entry') }}
