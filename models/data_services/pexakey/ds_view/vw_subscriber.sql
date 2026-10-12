

with source as (

    select * from {{ ref('rds_subscriber') }}

),

renamed as (

    select
        id
        ,version
        ,record_created
        ,record_updated
        ,subscriber_id
        ,subscriber_name
        ,inserted_at
        ,load_type
        ,effective_from
        ,effective_to
        ,inserted_at
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
   

)


select * from renamed
