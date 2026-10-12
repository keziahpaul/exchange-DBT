

with source as (

    select * from {{ ref('rds_tracking_user') }}

),

renamed as (

    select
        id
        ,version
        ,record_created
        ,record_updated
        ,user_email
        ,user_mobile
        ,user_family_name
        ,user_given_name
        ,user_org_name
        ,user_org_contact_given_name
        ,user_org_contact_family_name
        ,effective_from
        ,effective_to
        ,inserted_at
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
   

)


select * from renamed