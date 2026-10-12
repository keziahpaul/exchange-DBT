with source as (

    select * from {{  ref('pxa_settlement_categories') }}

),

renamed as (

    select
        settlement_category_id,
        name,
        type1,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed