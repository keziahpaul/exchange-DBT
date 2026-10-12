with source as (

    select * from {{ ref('pxa_org_types') }}

),

renamed as (

    select
        org_type_id,
        name,
        name_enum,
        category,
        acn_exempt,
        arbn_exempt,
        abn_status_enum,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed