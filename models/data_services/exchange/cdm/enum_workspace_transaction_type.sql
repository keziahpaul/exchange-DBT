{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/workspace/WorkspaceTransactionType.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, is_default
    FROM (VALUES
        ('TRANSFER', 'Transfer', FALSE),
        ('NON_TRANSFER', 'Non-Transfer', FALSE),
        ('CAVEAT', 'Caveat', FALSE),
        ('NOMINATION', 'Nomination', FALSE),
        ('OTHER_TRANSFER', 'Transfer Type', FALSE),
        ('OTHER_LEASE', 'Lease Type', FALSE),
        ('PART_TENANCY_TRANSFER', 'Part Tenancy Transfer', FALSE),
        ('PRIORITY_NOTICE', 'Priority Notice', FALSE),
        ('PURCHASE', 'Purchase', FALSE),
        ('REFINANCE', 'Refinance', FALSE),
        ('RESIDUAL_DOCUMENT', 'Residual Document', FALSE),
        ('RESIDUAL_SECTION_104_SURVEY', 'Transfer of Land Act - Section 104 - Plan or survey based', FALSE),
        ('RESIDUAL_SECTION_104_NON_SURVEY', 'Transfer of Land Act - Section 104 - NOT Plan or survey based', FALSE),
        ('RESIDUAL_MCP', 'Memorandum of Common Provisions (MCP)', FALSE),
        ('OTHER_RESIDUAL_DOCUMENT', 'Residual Document Type', FALSE),
        ('SALE', 'Sale', FALSE),
        ('STANDALONE_DISCHARGE', 'Standalone Discharge', FALSE),
        ('STANDALONE_MORTGAGE', 'Standalone Mortgage', FALSE),
        ('SURVIVORSHIP', 'Survivorship', FALSE),
        ('NOTICE_OF_DEATH', 'Notice of Death', FALSE),
        ('TRANSFER_BY_THIRD_PARTY', 'Transfer by Third Party', FALSE),
        ('TRANSFER_OF_ECT_CONTROL', 'Transfer of eCT Control', FALSE),
        ('TRANSFER_OF_INTEREST', 'Transfer of Interest', FALSE),
        ('TRANSMISSION', 'Transmission', FALSE),
        ('WITHDRAWAL_OF_CAVEAT', 'Withdrawal of Caveat', FALSE),
        ('RELATED_PARTIES_TRANSFER', 'Related Parties Transfer', FALSE),
        ('LEASE', 'Lease', FALSE),
        ('VARIATION_OF_LEASE', 'Variation of Lease', FALSE),
        ('SURRENDER_OF_LEASE', 'Surrender of Lease', FALSE),
        ('MORTGAGE_OF_LEASE', 'Mortgage of Lease', FALSE),
        ('TRANSMISSION_DIRECT_TO_BENEFICIARY', 'Transmission Direct to Beneficiary', FALSE),
        ('REMOVAL_OF_CAVEAT', 'Removal of Caveat', FALSE),
        ('ENCUMBRANCE', 'Encumbrance', FALSE),
        ('DISCHARGE_OF_ENCUMBRANCE', 'Discharge of Encumbrance', FALSE),
        ('CHANGE_OF_NAME', 'Change of Name', FALSE),
        ('RECORD_OF_DEATH', 'Record of Death', FALSE),
        ('OBTAIN_CONTROL_OF_TITLE_FROM_REGISTRAR', 'Obtain Control of Title from Registrar', FALSE),
        ('GIVE_CONTROL_OF_TITLE_TO_REGISTRAR', 'Give Control of Title to Registrar', FALSE),
        ('OTHER', 'Other', FALSE),
        ('OTHER_TYPE', 'Other Type', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 'Unknown Workspace Transaction Type', TRUE)
    ) v(enum_name, enum_value, is_default)
)
SELECT
    '2026-03-09 18:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,

    {#- one of these generated fields are meaningless when enum_name is '<NULL>' #}
    CASE WHEN enum_name IN (
        'SALE', 'PURCHASE', 'RELATED_PARTIES_TRANSFER', 'REFINANCE', 'OTHER_TRANSFER', 'PART_TENANCY_TRANSFER',
        'TRANSFER_OF_INTEREST', 'TRANSFER_BY_THIRD_PARTY', 'OTHER_TYPE'
    )
         THEN TRUE ELSE FALSE END AS default_financial_settlement_flag,
    CASE WHEN enum_name IN (
        'SALE', 'PURCHASE', 'RELATED_PARTIES_TRANSFER', 'OTHER_TRANSFER', 'PART_TENANCY_TRANSFER', 'TRANSFER_OF_INTEREST',
        'TRANSFER_BY_THIRD_PARTY'
    )
         THEN TRUE ELSE FALSE END AS default_involve_transfer_flag,
    CASE WHEN enum_name IN ('OTHER_TRANSFER', 'OTHER_LEASE', 'OTHER_RESIDUAL_DOCUMENT')
         THEN TRUE ELSE FALSE END AS has_child_options,
    CASE WHEN enum_name IN ('OTHER_LEASE', 'OTHER_TRANSFER', 'OTHER_TYPE', 'OTHER', 'TRANSFER', 'NON_TRANSFER')
         THEN TRUE ELSE FALSE END AS excluded_from_options,
    CASE WHEN enum_name IN ('TRANSFER', 'NON_TRANSFER', 'OTHER')
         THEN TRUE ELSE FALSE END AS added_at_the_bottom,
    CASE WHEN enum_name IN (
        'CAVEAT', 'WITHDRAWAL_OF_CAVEAT', 'TRANSMISSION', 'SURVIVORSHIP', 'RESIDUAL_DOCUMENT', 'PRIORITY_NOTICE', 'REFINANCE',
        'STANDALONE_DISCHARGE', 'STANDALONE_MORTGAGE', 'TRANSFER_OF_ECT_CONTROL', 'TRANSMISSION_DIRECT_TO_BENEFICIARY', 'LEASE',
        'NOTICE_OF_DEATH', 'VARIATION_OF_LEASE', 'SURRENDER_OF_LEASE', 'MORTGAGE_OF_LEASE', 'REMOVAL_OF_CAVEAT', 'ENCUMBRANCE',
        'DISCHARGE_OF_ENCUMBRANCE', 'CHANGE_OF_NAME', 'RECORD_OF_DEATH', 'OBTAIN_CONTROL_OF_TITLE_FROM_REGISTRAR',
        'GIVE_CONTROL_OF_TITLE_TO_REGISTRAR', 'OTHER'
    )
         THEN FALSE ELSE TRUE END AS not_involved_in_transfer,
    CASE WHEN enum_name IN ('RELATED_PARTIES_TRANSFER', 'PART_TENANCY_TRANSFER')
         THEN TRUE ELSE FALSE END AS has_optional_settle_datetime
FROM enum
