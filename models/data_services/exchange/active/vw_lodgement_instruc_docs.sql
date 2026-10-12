with source as (

    select * from {{ ref('pxa_lodgement_instruc_docs') }}

),

renamed as (

    select
        document_id,
        instructions_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed