with 

source as (

    select * from {{ ref('pxa_document_property_ref') }}

),

renamed as (

    select
        document_id,
        property_ref_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'
)

select * from renamed
