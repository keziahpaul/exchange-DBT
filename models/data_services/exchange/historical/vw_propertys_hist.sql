with source as (

    select * from {{  ref('pxa_propertys') }}

),

renamed as (

    select
        property_id,
        land_identifier,
        description,
        workspace_id,
        property_detail_id,
        date_added,
        lvreport_address,
        updated_address_display,
        parent_indicator,
        initial_ris_date,
        lot_in_unregistered_plan,
        ltrv_warning_code,
        ct_controller_abn,
        ct_controller_customer_code,
        ct_controller_name,
        lot_on_plan_id,
        interop_title_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed