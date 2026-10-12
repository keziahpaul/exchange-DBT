{{ config (
    materialized="view"
)
}}


     select 
        subscriber_id,
        imt_provider_id,
        extraction_start_ts,
        inserted_at 
    from {{ ref('stg_pxa_subscriber_imt_provider') }}
