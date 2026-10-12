

with source as (

    select * from {{ ref('rds_address') }}

),

renamed as (

    select
        id
        ,version
        ,record_created
        ,record_updated
        ,unstructured_address
        ,address_line
        ,suburb
        ,state
        ,postcode
        ,property_classification
        ,tracking_user_reference
        ,effective_from
        ,effective_to
        ,inserted_at
        updated_at

    from source
   

)


select * from renamed
