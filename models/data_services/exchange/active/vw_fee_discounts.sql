with source as (

    select * from {{ ref('pxa_fee_discounts') }}

),

renamed as (

    select
        subscriber_id,
        jurisdiction,
        discount,
        start_date,
        end_date,
        role,
        inserted_at

    from source

)


select * from renamed