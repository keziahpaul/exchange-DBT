

with source as (

    select * from {{ ref('pxa_accounts') }}

),

renamed as (

    select
        account_id,
        version,
        type1,
        holder,
        bsb,
        number1,
        financialaccount_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed