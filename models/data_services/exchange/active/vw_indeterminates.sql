with source as (

    select * from {{ ref('pxa_indeterminates') }}

),

renamed as (

    select
        party_id,
        legal_entity_name,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed