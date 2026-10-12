{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/document/DocumentTypeEnum.java @release/R.23.01.00 -#}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/document/DocumentTypeDaoImpl.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, description, lodgement_order, is_default
    FROM (VALUES
        ('MORTGAGE', 1, 'Mortgage', NULL, FALSE),
        ('DISCHARGE_OF_MORTGAGE', 2, 'Discharge of Mortgage', 3, FALSE),
        ('CORD_HOLDER_CONSENT', 3, 'Cord Holder Consent', NULL, FALSE),
        ('LODGEMENT_INSTRUCTIONS', 4, 'Lodgement Instructions', NULL, FALSE),
        ('TRANSFER', 5, 'Transfer', 13, FALSE),
        ('CAVEAT', 6, 'Caveat', 17, FALSE),
        ('WITHDRAWAL_OF_NOMINATION', 7, 'Withdrawal of Nomination', NULL, FALSE),
        ('SETTLEMENT_STATEMENT', 8, 'Settlement Statement', NULL, FALSE),
        ('WITHDRAWAL_OF_CAVEAT', 9, 'Withdrawal of Caveat', 2, FALSE),
        ('NOTICE_OF_SALE', 10, 'Notice of Sale', NULL, FALSE),
        ('NOTICE_OF_ACQUISITION', 11, 'Notice Of Acquisition', NULL, FALSE),
        ('SETTLEMENT_NOTICE', 12, 'Settlement Notice', NULL, FALSE),
        ('WITHDRAWAL_SETTLEMENT_NOTICE', 13, 'Removal of Settlement Notice', NULL, FALSE),
        ('NOTICE_OF_SALE_FORM_24A', 14, 'Form 24 Part A', NULL, FALSE),
        ('NOTICE_OF_SALE_FORM_24B', 15, 'Form 24 Part B', NULL, FALSE),
        ('NOTICE_OF_SALE_FORM_25', 16, 'Form 25', NULL, FALSE),
        ('NOTICE_OF_CHARGE', 17, 'Notice of Statutory Charge', NULL, FALSE),
        ('NOTICE_OF_CHARGE_WITHDRAWAL', 18, 'Removal of Notice of Statutory Charge', NULL, FALSE),
        ('PRIORITY_NOTICE', 19, 'Priority Notice', NULL, FALSE),
        ('WITHDRAWAL_OF_PRIORITY_NOTICE', 20, 'Withdrawal of Priority Notice', 1, FALSE),
        ('EXTENSION_OF_PRIORITY_NOTICE', 21, 'Extension of Priority Notice', NULL, FALSE),
        ('NATIONAL_MORTGAGE', 22, 'National Mortgage', 15, FALSE),
        ('TRANSFER_OF_CT_CONTROL', 23, 'Transfer of CT Control', NULL, FALSE),
        ('DISCHARGE_OF_ENCUMBRANCE', 24, 'Discharge of Encumbrance', 6, FALSE),
        ('ENCUMBRANCE', 25, 'Encumbrance', 14, FALSE),
        ('SURVIVORSHIP', 26, 'Survivorship', 8, FALSE),
        ('TRANSMISSION', 27, 'Transmission', 9, FALSE),
        ('TRANSFER_BY_THIRD_PARTY', 28, 'Transfer by Third Party', 10, FALSE),
        ('TRANSMISSION_DIRECT_TO_BENEFICIARY', 29, 'Transmission Direct to Beneficiary', 11, FALSE),
        ('TRANSFER_OF_INTEREST', 30, 'Transfer of Interest', 12, FALSE),
        ('LEASE', 31, 'Lease', 16, FALSE),
        ('SURRENDER_OF_LEASE', 32, 'Surrender of Lease', 4, FALSE),
        ('RESIDUAL', 33, 'Residual Document', 5, FALSE),
        ('CHANGE_OF_NAME', 34, 'Change of Name', 7, FALSE),
        ('OBTAIN_CONTROL_OF_TITLE_FROM_REGISTRAR', 35, 'Obtain Control of Title from Registrar', NULL, FALSE),
        ('GIVE_CONTROL_OF_TITLE_TO_REGISTRAR', 36, 'Give Control of Title to Registrar', NULL, FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 0, 'Unknown Document Type', NULL, TRUE)
    ) v(enum_name, enum_value, description, lodgement_order, is_default)
)
SELECT
    '2026-03-12 12:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,
    description,
    lodgement_order,

    CASE WHEN enum_name IN (
        'MORTGAGE', 'NATIONAL_MORTGAGE', 'DISCHARGE_OF_MORTGAGE', 'CAVEAT', 'WITHDRAWAL_OF_CAVEAT', 'TRANSFER',
        'CORD_HOLDER_CONSENT', 'WITHDRAWAL_OF_NOMINATION', 'SETTLEMENT_NOTICE', 'WITHDRAWAL_SETTLEMENT_NOTICE',
        'NOTICE_OF_CHARGE', 'NOTICE_OF_CHARGE_WITHDRAWAL', 'TRANSFER_OF_INTEREST'
    )
         THEN TRUE ELSE FALSE END AS non_supporting_doc_type,
    CASE WHEN enum_name IN (
        'NOTICE_OF_ACQUISITION', 'NOTICE_OF_SALE', 'NOTICE_OF_SALE_FORM_24A', 'NOTICE_OF_SALE_FORM_24B',
        'NOTICE_OF_SALE_FORM_25', 'EXTENSION_OF_PRIORITY_NOTICE', 'SETTLEMENT_STATEMENT',
        'WITHDRAWAL_OF_PRIORITY_NOTICE'
    )
         THEN TRUE ELSE FALSE END AS non_create_document_doc_type,
    CASE WHEN enum_name IN ('NOTICE_OF_SALE', 'NOTICE_OF_ACQUISITION', 'NOTICE_OF_SALE_FORM_24A', 'NOTICE_OF_SALE_FORM_24B', 'NOTICE_OF_SALE_FORM_25')
         THEN TRUE ELSE FALSE END AS transfer_supporting_doc_type,
    CASE WHEN enum_name IN ('MORTGAGE', 'SETTLEMENT_NOTICE', 'WITHDRAWAL_SETTLEMENT_NOTICE')
         THEN TRUE ELSE FALSE END AS expired_doc_type,
    CASE WHEN enum_name IN ('TRANSFER_OF_CT_CONTROL')
         THEN TRUE ELSE FALSE END AS no_lv_doc_type,
    CASE WHEN enum_name IN ('DISCHARGE_OF_MORTGAGE', 'NATIONAL_MORTGAGE')
           OR no_lv_doc_type
         THEN TRUE ELSE FALSE END AS bypass_lv_for_signing_doc_type,
    CASE WHEN enum_name IN ('TRANSFER_OF_CT_CONTROL')
         THEN TRUE ELSE FALSE END AS standalone_doc_type,
    CASE WHEN enum_name IN ('TRANSFER', 'TRANSFER_BY_THIRD_PARTY', 'TRANSMISSION_DIRECT_TO_BENEFICIARY', 'TRANSFER_OF_INTEREST')
         THEN TRUE ELSE FALSE END AS funds_confirmation_doc_type,
    CASE WHEN enum_name IN ('LODGEMENT_INSTRUCTIONS', 'PRIORITY_NOTICE', 'EXTENSION_OF_PRIORITY_NOTICE', 'WITHDRAWAL_OF_PRIORITY_NOTICE')
         THEN TRUE ELSE FALSE END AS settlement_not_required_doc_type,
    CASE WHEN enum_name IN ('SURVIVORSHIP', 'TRANSMISSION', 'TRANSFER', 'TRANSMISSION_DIRECT_TO_BENEFICIARY', 'RESIDUAL')
         THEN TRUE ELSE FALSE END AS tenancy_changing_doc_type,
    CASE WHEN enum_name IN ('PRIORITY_NOTICE', 'WITHDRAWAL_OF_PRIORITY_NOTICE', 'EXTENSION_OF_PRIORITY_NOTICE')
         THEN TRUE ELSE FALSE END AS priority_notice_doc_type,
    CASE WHEN enum_name IN ('SETTLEMENT_STATEMENT', 'LODGEMENT_INSTRUCTIONS', 'EXTENSION_OF_PRIORITY_NOTICE', 'WITHDRAWAL_OF_PRIORITY_NOTICE')
           OR transfer_supporting_doc_type
         THEN TRUE ELSE FALSE END AS without_li_doc_type,
    CASE WHEN enum_name IN ('TRANSFER', 'TRANSFER_OF_INTEREST', 'LEASE', 'SURRENDER_OF_LEASE', 'RESIDUAL')
         THEN TRUE ELSE FALSE END AS possible_multi_counter_part_doc_type,
    CASE WHEN enum_name IN ('TRANSFER', 'TRANSFER_BY_THIRD_PARTY', 'TRANSMISSION_DIRECT_TO_BENEFICIARY', 'TRANSFER_OF_INTEREST', 'SURRENDER_OF_LEASE')
         THEN TRUE ELSE FALSE END AS transfer_related_doc_type,
    CASE WHEN enum_name IN (
        'DISCHARGE_OF_MORTGAGE', 'TRANSFER', 'MORTGAGE', 'NATIONAL_MORTGAGE', 'TRANSFER_BY_THIRD_PARTY',
        'TRANSFER_OF_INTEREST', 'SURVIVORSHIP', 'TRANSMISSION'
    )
         THEN TRUE ELSE FALSE END AS requires_cord_consent_doc_type,
    CASE WHEN enum_name IN ('CORD_HOLDER_CONSENT', 'WITHDRAWAL_OF_NOMINATION', 'OBTAIN_CONTROL_OF_TITLE_FROM_REGISTRAR', 'GIVE_CONTROL_OF_TITLE_TO_REGISTRAR')
         THEN TRUE ELSE FALSE END AS auto_lodge_doc_type,
    CASE WHEN enum_name IN ('MORTGAGE', 'NATIONAL_MORTGAGE', 'DISCHARGE_OF_MORTGAGE', 'LODGEMENT_INSTRUCTIONS')
         THEN TRUE ELSE FALSE END AS iop_supported_doc_type

FROM enum
{#- pxa_document_type also has
     sequence_id  int
     has_sdv      bool
#}
