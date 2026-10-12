with 

source as (

    select * from {{ ref('pxa_reference_data') }}

),

renamed as (

    select
        reference_data_id,
        reference_data_key,
        context_code,
        value,
        description,
        effective_date,
        expiry_date,
        sort_index,
        version,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
