with source as (

    select * from {{ ref('pxa_participant_partys') }}

),

renamed as (

    select
        participant_id,
        party_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed