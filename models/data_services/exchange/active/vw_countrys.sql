with source as (

    select * from {{ ref('pxa_countrys') }}

),

renamed as (

    select
        country_id,
        name,
        country_code,
        short_name,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed