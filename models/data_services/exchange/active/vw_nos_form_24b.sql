with 

source as (

    select * from {{ ref('pxa_nos_form_24b') }}

),

renamed as (

    select
        document_id,
        electrical_safety,
        safety_informed,
        smoke_alarm,
        smoke_alarm_informed,
        has_agreement,
        party_related_to_transferdate,
        degree_of_relationship,
        cons_less_unencumbered,
        part_of_agreement,
        gst_payable,
        under_margin_scheme,
        date_of_written_agreement,
        selected_transferor,
        non_australian_entity,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
      where effective_to::date = '{{var('active_date')}}'

)

select * from renamed
