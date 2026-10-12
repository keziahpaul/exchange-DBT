with source as (

    select * from {{ ref('subscriber_to_tnc') }}

),

renamed as (

    select
        id,
        tnc_version,
        subscriber_id,
        for_pot,
        for_mot,
        accepted_on,
        default_login_as_pot,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
