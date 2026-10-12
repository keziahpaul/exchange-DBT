with source as (

    select * from {{ ref('pxa_document_types') }}

),

renamed as (

    select
        document_type_id,
        value1,
        sequence_id,
        has_sdv,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed