{{ config (
    materialized="view"
)
}}

select * from {{ ref('web_app_registration_ms') }}
