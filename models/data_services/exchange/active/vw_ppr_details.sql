with 

source as (

    select * from {{ ref('pxa_ppr_details') }}

),

renamed as (

    select
        ppr_details_id,
        party_id,
        is_transferee_ppr,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
