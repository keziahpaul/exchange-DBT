

with source as (

    select * from {{ ref('rds_task') }}

),

renamed as (

    select
        id
        ,version
        ,record_created
        ,record_updated
        ,task_id
        ,task_type
        ,task_status
        ,task_detail
        ,tracking_reference
        ,task_expired
        ,task_is_viewed
        ,tracking_user_reference
        ,effective_from
        ,effective_to
        ,inserted_at
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
   

)


select * from renamed