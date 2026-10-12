with source as (

    select * from {{  ref('pxa_proprietor_groups') }}

),

renamed as (

    select
        proprietior_group_id,
        group_type,
        share_numerator,
        share_denominator,
        is_no_survivorship,
        min_number_of_trustees,
        is_transacting_prop_grp,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed