with source as (

    select * from {{ ref('pxa_correspondences') }}

),

renamed as (

    select
        correspondence_id,
        version,
        acct_stmt_freq,
        phone_number,
        fax_number,
        email_address,
        general_email_address,
        address_id,
        dx_address_id,
        preference,
        first_name,
        middle_name,
        last_name,
        label,
        username,
        subscriber_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at
    from source
    where effective_to::date = '{{ var('active_date') }}'
)

select * from renamed
