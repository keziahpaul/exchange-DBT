with source as (

    select * from {{ ref('pxa_billing_transactions') }}

),

renamed as (

    select
        bllng_rqst_trnsctns_id,
        jurisdiction,
        subscriber_id,
        subscriber_billing_entity,
        subscriber_user,
        requesting_role,
        title_reference,
        bundle_type,
        bundle_subscription_id,
        billing_date,
        fee_category,
        request_date,
        billing_status,
        fee_amount,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed