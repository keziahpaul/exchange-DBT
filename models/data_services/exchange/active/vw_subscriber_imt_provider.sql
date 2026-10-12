with source as (

    select * from {{  ref('pxa_subscriber_imt_provider') }}

),

renamed as (

    select
        subscriber_id,
        imt_provider_id,
        inserted_at
    from source

)


select * from renamed