with source as (

    select * from {{ ref('pxa_document_signatures') }}

),

renamed as (

    select
        document_id,
        signature_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed