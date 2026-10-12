with source as (

    select * from {{  ref('pxa_sub_opera_jurisdictions') }}

),

renamed as (

    select
        opera_jurisdiction_id,
        subscriber_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed