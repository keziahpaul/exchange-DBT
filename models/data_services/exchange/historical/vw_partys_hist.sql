with source as (

    select * from {{ ref('pxa_partys') }}

),

renamed as (

    select
        party_id,
        version,
        workspace_id,
        address,
        updated_name,
        phone_number,
        title_party_full_name,
        source,
        notice_address,
        delivery_address,
        name_on_title,
        previous_name,
        del_address_diff,
        address_justification,
        fax_number,
        is_foreign_transferee,
        is_trustee,
        trust_name,
        foreign_type,
        self_representing_sub_id,
        subscriber_id,
        created_by_subscriber,
        ris_address,
        has_previously_held_land,
        duplicate_party_name,
        email_address,
        party_poa_id,
        other_names_flag,
        settleme_account_id,
        is_settle_me,
        interop_party_id,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed