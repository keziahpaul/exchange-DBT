with source as (

    select * from {{ ref('pxa_simultaneous_lodgements') }}

),

renamed as (

    select
        simultaneous_lodgement_id,
        link_type,
        requesting_workspace_id,
        accepting_workspace_id,
        requesting_participant,
        accepting_participant,
        owner_id,
        date_accepted,
        status,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source

)

select * from renamed
