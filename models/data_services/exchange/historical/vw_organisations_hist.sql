with source as (

    select * from {{ ref('pxa_organisations') }}

),

renamed as (

    select
        party_id,
        name,
        abn,
        org_type_id,
        identifiertype,
        identifiervalue,
        trading_name,
        business_name,
        business_unit,
        arb,
        acn,
        acln,
        gpr,
        administration_status1,
        administration_status2,
        country,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed