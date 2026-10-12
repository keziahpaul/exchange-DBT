{{ config (
    materialized="view"
)
}}


select 
        proprietor_group_id,
        party_id,
        extraction_start_ts,
        inserted_at
from {{ ref('stg_pxa_group_proprietors') }}
