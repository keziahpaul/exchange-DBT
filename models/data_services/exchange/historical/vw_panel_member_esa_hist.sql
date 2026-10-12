with source as (

    select * from {{ ref('pxa_panel_member_esa') }}

),

renamed as (

    select
        panel_member_id,
        panel_master_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed