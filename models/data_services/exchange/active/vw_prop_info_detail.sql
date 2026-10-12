with 

source as (

    select * from {{ ref('pxa_prop_info_detail') }}

),

renamed as (

    select
        property_information_detail_id,
        property_group_id,
        ispropertyknown,
        area,
        measurement,
        primary_land_use,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
