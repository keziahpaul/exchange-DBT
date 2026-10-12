with source as (

    select * from {{ ref('pxa_passwords') }}

),

renamed as (

    select
        password_id,
        version,
        changed,
        locked,
        failed_attempts,
        reset_requested,
        reset_requested_count,
        reset_token,
        user_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed