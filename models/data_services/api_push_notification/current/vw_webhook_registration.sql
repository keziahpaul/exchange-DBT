

with source as (

    select * from {{ ref('webhook_registration_curate') }}

),

renamed as (

    select
        registration_id 
        ,webhook_uri 
        ,current_shared_secret 
        ,current_shared_secret_expiry
        ,previous_shared_secret 
        ,previous_shared_secret_expiry 
        ,inserted_at_raw 
        ,effective_from 
        ,effective_to 
        ,inserted_at 
        ,updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
