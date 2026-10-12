with source as (

    select * from {{ ref('pxa_lodgeins_dealing_require') }}

),

renamed as (

    select
        dealing_req_id,
        document_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed