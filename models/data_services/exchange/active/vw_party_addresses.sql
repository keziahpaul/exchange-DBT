with source as (

    select * from {{ ref('pxa_party_addresses') }}

),

renamed as (

    select
        party_address_id,
        address_id,
        party_id,
        document_id,
        doc_address_type,
        frequent_rep_party_id,
        address_usage_type,
        address_usage_source,
        no_address_reason,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed