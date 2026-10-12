with source as (

    select * from {{ ref('pd_user_authorised') }}

),

renamed as (

    select
        id,
        subscriber_id,
        pot,
        mot,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
    where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
