with source as (

    select * from {{ ref('pxa_addresses') }}

),

renamed as (

    select
        address_id,
        version,
        street,
        suburb,
        post_code,
        state,
        country_id,
        unit_type,
        unit_number,
        level_type,
        level_number,
        lot_number,
        complex_name,
        road_number,
        road_name,
        road_type,
        road_suffix,
        postal_delivery_type,
        postal_delivery_number,
        address_site_name,
        locality_name,
        road_number2,
        road_name2,
        road_type2,
        road_suffix2,
        building_name1,
        building_name2,
        address_type,
        fax_number,
        overseas_address1,
        overseas_address2,
        overseas_address3,
        dx_address_id,
        overseas_address4,
        address_label,
        road_number1,
        road_name1,
        road_type1,
        road_suffix1,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed