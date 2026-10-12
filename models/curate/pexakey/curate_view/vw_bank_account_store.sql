{{ config (
    materialized="view"
)
}}

select * from {{ ref('ms_api_bank_account_store') }}
