with 

source as (

    select * from {{ ref('pxa_ppr_details_list') }}

),

renamed as (

    select
        document_id,
        ppr_details_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
