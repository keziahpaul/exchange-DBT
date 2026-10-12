{{ config (
    materialized="view"
)
}}

     select 
        subscriber_id,
        jurisdiction,
        discount,
        start_date,
        end_date,
        role,
        extraction_start_ts,
        inserted_at
    from {{ ref('stg_pxa_fee_discounts') }}
    