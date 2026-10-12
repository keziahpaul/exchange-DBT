{{ config (
    materialized="view"
)
}}

select * from {{ ref('ms_api_property_settlement') }}
