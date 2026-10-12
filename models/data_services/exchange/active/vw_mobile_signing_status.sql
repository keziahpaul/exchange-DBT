with source as (

    select * from {{ ref('pxa_mobile_signing_status') }}

),

renamed as (

    select
        mobile_signing_status_id,
        subscriber_id,
        user_id,
        status,
        created_date,
        created_by,
        last_updated_date,
        last_updated_by,
        has_transitioned,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
