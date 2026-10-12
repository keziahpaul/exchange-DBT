
with source as (

    select * from {{ ref('financial_accounts_audit') }}

),

renamed as (

    select
        id,
        pot_project_id,
        mot_project_id,
        user_id,
        action_date,
        action,
        before_description,
        after_description,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)

select * from renamed
