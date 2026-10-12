
with source as (

    select * from {{  ref('pxa_subscriber_panel_members') }}

),

renamed as (

    select
        panel_member_id,
        subscriber_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
