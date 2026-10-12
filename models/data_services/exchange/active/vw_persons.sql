with source as (

    select * from {{ ref('pxa_persons') }}

),

renamed as (

    select
        party_id,
        first_name,
        middle_name,
        last_name,
        namesuffix,
        full_name,
        date_of_birth,
        first_name_2,
        name_title,
        first_name_3,
        first_name_4,
        last_name_order,
        abn,
        arb,
        acn,
        acln,
        gpr,
        is_sole_trader,
        is_resident_transferee,
        country,
        is_deceased,
        is_settle_me,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed