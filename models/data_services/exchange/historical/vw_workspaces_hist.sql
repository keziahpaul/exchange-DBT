with source as (

    select * from {{ ref('pxa_workspaces') }}

),

renamed as (

    select
        workspace_id,
        version,
        number1,
        jurisdiction,
        status,
        privacy,
        archive_warning,
        archived,
        abandoned,
        bundle_type,
        last_accessed,
        transaction_type,
        date_linked,
        transaction_scope,
        panel_master_selected,
        is_ready_to_book,
        is_interop,
        is_interop_ready,
        interop_lock_status,
        is_interop_archived,
        is_pelno,
        interop_lock_id,
        created_date,
        necds_version,
        manual_settlement_category,
        manual_settlement_reason,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source

)


select * from renamed