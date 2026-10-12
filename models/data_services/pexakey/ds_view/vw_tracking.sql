

with source as (

    select * from {{ ref('rds_tracking') }}

),

renamed as (

    select
        id
        ,version
        ,record_created
        ,record_updated
        ,tracking_id
        ,tracking_status
        ,invitation_date
        ,workspace_internal_id
        ,settlement_date
        ,workspace_status
        ,party_id
        ,role
        ,correlation_token
        ,subscriber_reference
        ,tracking_user_reference
        ,address_reference
        ,display_name
        ,party_type
        ,tracking_expired
        ,is_hidden
        ,subscriber_mobile
        ,settlement_status
        ,is_settlement_ready
        ,effective_from
        ,effective_to
        ,inserted_at
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
   

)


select * from renamed