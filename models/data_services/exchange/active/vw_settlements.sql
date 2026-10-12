with source as (

    select * from {{  ref('pxa_settlements') }}

),

renamed as (

    select
        settlement_id,
        version,
        type1,
        status,
        date1,
        time1,
        lastupdatedby,
        stopsettlementdate,
        lastupdateddate,
        lastupdatedreason,
        workspace_id,
        external_funds,
        net_adjustments,
        link_type,
        settletime_slot_id,
        rits_status,
        settlement_failure_id,
        ext_failure_reason,
        settlement_tracking_status,
        orig_settle_date,
        orig_settle_time,
        disburse_interim_flag,
        subscriber_id,
        proposal_reason,
        deleted_source,
        deleted_destination,
        last_updated_by_username,
        last_updated_by_subscriber_id,
        last_updated_by_system_user,
        funds_required_to_settle_amt,
        frs_updated_by_subs_id,
        frs_last_updated,
        frs_shortfall_flag,
        frs_shortfall_last_updated,
        frs_shortfall_updated_subs_id,
        frs_shortfall_acct_last_four,
        vendor_surplus_to,
        vendor_surplus_last_updated,
        vendor_surplus_last_updated_by,
        new_fss_on,
        auto_calculate_vendor_surplus,
        fss_partial_view,
        is_interop_fss_ready,
        interop_settlement_status,
        interop_settlement_datetime,
        interop_settlement_lock_status,
        effective_from,
        effective_to,
        inserted_at,
        updated_at

    from source
          where effective_to::date = '{{var('active_date')}}'
)


select * from renamed