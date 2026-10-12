{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'id',
        merge_update_columns = ['deleted_at']
    )
}}

WITH docs AS (
    SELECT
        id,
        document_type_id,
        created_date,
        COALESCE(parent_document, -1) AS parent_document,
        FIRST_VALUE(lodgement_id) OVER (PARTITION BY id ORDER BY date_changed) AS lodgement_id,
        workspace_id,
        FIRST_VALUE(created_by_role_id) OVER (PARTITION BY id ORDER BY date_changed) AS created_by_role_id,
        FIRST_VALUE(created_by_subscriber_id) OVER (PARTITION BY id ORDER BY date_changed) AS created_by_subscriber_id,
        FIRST_VALUE(participant_id) OVER (PARTITION BY id ORDER BY date_changed) AS participant_id,
        date_changed AS inserted_at,
        IFF(is_delete, date_changed, NULL) AS deleted_at
    FROM {{ ref('stg_cdm_lodgement_document_event') }}
    {%- if is_incremental() %}
    WHERE date_changed > COALESCE((SELECT {{ dms_timestamp_trunc('MAX(inserted_at)') }} FROM {{ this }}), '1900-01-01')
    {%- endif %}
),
dim_docs AS (
    SELECT
        id,
        document_type_id,
        created_date,
        parent_document,
        lodgement_id,
        workspace_id,
        created_by_role_id,
        created_by_subscriber_id,
        participant_id,
        MIN(inserted_at) AS inserted_at,
        MAX(deleted_at) AS deleted_at
    FROM docs
    GROUP BY ALL
)
SELECT
    d.id,
    d.inserted_at,
    d.deleted_at,
    d.document_type_id,
    d.created_date,
    d.parent_document,
    d.lodgement_id,
    d.workspace_id,
    d.created_by_role_id,
    d.created_by_subscriber_id,
    d.participant_id,
    e.enum_name AS document_type_name,
    e.description,
    e.lodgement_order,
    e.non_supporting_doc_type,
    e.non_create_document_doc_type,
    e.transfer_supporting_doc_type,
    e.expired_doc_type,
    e.no_lv_doc_type,
    e.bypass_lv_for_signing_doc_type,
    e.standalone_doc_type,
    e.funds_confirmation_doc_type,
    e.settlement_not_required_doc_type,
    e.tenancy_changing_doc_type,
    e.priority_notice_doc_type,
    e.without_li_doc_type,
    e.possible_multi_counter_part_doc_type,
    e.transfer_related_doc_type,
    e.requires_cord_consent_doc_type,
    e.auto_lodge_doc_type,
    e.iop_supported_doc_type
FROM dim_docs d
LEFT JOIN {{ ref('enum_document_type') }} e ON d.document_type_id = e.enum_value
ORDER BY d.id
