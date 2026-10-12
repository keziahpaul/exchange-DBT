with source as (

    select * from {{ ref('pxa_business_event_reference') }} 

),

renamed as (

    select
        business_event_reference_id,
        business_event_ref_type_id,
        reference_id,
        business_event_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
