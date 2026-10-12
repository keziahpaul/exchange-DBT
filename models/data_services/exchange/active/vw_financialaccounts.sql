with source as (

    select * from {{ ref('pxa_financialaccounts') }}

),

renamed as (

    select
        financialaccount_id,
        version,
        name,
        type1,
        description,
        bsb,
        number1,
        status,
        date1,
        subscriber_id,
        financial_institution_id,
        delete_flag,
        last_modified_by,
        created_date,
        restriction,
        cust_identifier,
        dual_verification_enabled,
        jurisdiction,
        status_changed_date,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
      where effective_to::date = '{{var('active_date')}}'
)


select * from renamed