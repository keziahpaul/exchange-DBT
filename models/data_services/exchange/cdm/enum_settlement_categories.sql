{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/settlement/SettlementCategoryTypeEnum.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}
{#- This looks a LOT like pxa_settlement_categories -#}

WITH enum AS (
    SELECT enum_name, enum_value, settlement_category_type, description, is_account_bpay_lockable, is_default
    FROM (VALUES
        ('LOAN_PROCEEDS_SOURCE', 1, 'SOURCE', 'Loan Proceeds', FALSE, FALSE),
        ('PURCHASERS_EQUITY_SOURCE', 2, 'SOURCE', 'Purchaser''s Equity', FALSE, FALSE),
        ('VENDORS_FUNDS_SOURCE', 3, 'SOURCE', 'Vendor''s Funds', FALSE, FALSE),
        ('FIRST_HOME_OWNERS_GRANT_SOURCE', 4, 'SOURCE', 'First Home Owner''s Grant', FALSE, FALSE),
        ('PEXA_SEQUENTIAL_SETTLEMENT_SOURCE', 5, 'SOURCE', 'PEXA Sequential Settlement', FALSE, FALSE),
        ('LOAN_PAYOUT_DISBURSEMENT', 6, 'DISBURSEMENT', 'Loan Payout', TRUE, FALSE),
        ('VENDORS_FUNDS_DISBURSEMENT', 7, 'DISBURSEMENT', 'Vendor''s Funds', TRUE, FALSE),
        ('PEXA_SEQUENTIAL_SETTLEMENT_DISBURSEMENT', 8, 'DISBURSEMENT', 'PEXA Sequential Settlement', FALSE, FALSE),
        ('LODGEMENT_FEES_DISBURSEMENT', 9, 'DISBURSEMENT', 'Lodgement Fees', FALSE, FALSE),
        ('STAMP_DUTY_DISBURSEMENT', 10, 'DISBURSEMENT', 'Stamp Duty Disbursement', FALSE, FALSE), {#- WA and Qld translate this to TRANSFER_DUTY_DISBURSEMENT #}
        ('REGULAR_BENEFICIARIES_DISBURSEMENT', 11, 'DISBURSEMENT', 'Regular Beneficiaries', FALSE, FALSE),
        ('OTHER_DISBURSEMENT', 13, 'DISBURSEMENT', 'Other', TRUE, FALSE),
        ('FUNDS_FOR_STAMP_DUTY_SOURCE', 15, 'SOURCE', 'Funds for Stamp Duty', FALSE, FALSE), {#- WA and Qld translate this description to 'Funds for Transfer Duty' #}
        ('LINKED_FINANCIAL_SETTLEMENT_SOURCE', 16, 'SOURCE', 'Linked Financial Settlement', FALSE, FALSE),
        ('VENDOR_TO_PAY_SOURCE', 17, 'SOURCE', 'Vendor to Pay', FALSE, FALSE),
        ('THIRD_PARTY_BENEFICIARY_DISBURSEMENT', 18, 'DISBURSEMENT', 'Third Party Beneficiary', TRUE, FALSE),
        ('LINKED_FINANCIAL_SETTLEMENT_DISBURSEMENT', 19, 'DISBURSEMENT', 'Linked Financial Settlement', FALSE, FALSE),
        ('OTHER_SOURCE', 20, 'SOURCE', 'Other', FALSE, FALSE),
        ('PEXA_FEES_DISBURSEMENT', 21, 'DISBURSEMENT', 'PEXA Fees', FALSE, FALSE),
        ('LODGEMENT_FEES_SOURCE', 22, 'SOURCE', 'Lodgement Fees', FALSE, FALSE),
        ('PEXA_FEES_SOURCE', 23, 'SOURCE', 'PEXA Fees', FALSE, FALSE),
        ('TRANSFER_DUTY_DISBURSEMENT', 24, 'DISBURSEMENT', 'Transfer Duty', FALSE, FALSE),
        ('WATER_RATES_DISBURSEMENT', 28, 'DISBURSEMENT', 'Water Rates', TRUE, FALSE),
        ('COUNCIL_RATES_DISBURSEMENT', 29, 'DISBURSEMENT', 'Council Rates', TRUE, FALSE),
        ('BODYCORPORATE_FEES_DISBURSEMENT', 30, 'DISBURSEMENT', 'Body Corporate Fees', TRUE, FALSE),
        ('FUNDS_FOR_LODGEMENT_FEE_SOURCE', 25, 'SOURCE', 'Funds for Lodgement Fee', FALSE, FALSE),
        ('FUNDS_FOR_PEXA_FEE_SOURCE', 26, 'SOURCE', 'Funds for PEXA Fee', FALSE, FALSE),
        ('PROFESSIONAL_FEES_DISBURSEMENT', 27, 'DISBURSEMENT', 'Professional Fees', TRUE, FALSE),
        ('STAMP_DUTY_DISBURSEMENT_SA', 14, 'DISBURSEMENT',  'Stamp Duty', FALSE, FALSE),
        ('FOREIGN_RESIDENT_CAPITAL_GAINS_WITHHOLDING', 31, 'DISBURSEMENT', 'Foreign Resident Capital Gains Withholding', FALSE, FALSE),
        ('GST_WITHHOLDING', 32, 'DISBURSEMENT', 'GST Withholding', FALSE, FALSE),
        ('STEWART_TITLE', 33, 'DISBURSEMENT', 'Stewart Title', FALSE, FALSE),
        ('FOREIGN_RESIDENT_CAPITAL_GAINS_WITHHOLDING_ATO', 34, 'DISBURSEMENT',  'Foreign Resident Capital Gains Withholding - ATO Provided', FALSE, FALSE),
        ('PROPERTY_CLEARANCE_CERTIFICATE_PAYMENT', 35, 'DISBURSEMENT', 'Property Clearance Certificate - Land Tax', FALSE, FALSE),
        ('HOMES_FOR_HOMES_DONATION', 36, 'DISBURSEMENT', 'Homes for Homes Donation', FALSE, FALSE),
        ('NSW_LAND_TAX', 37, 'DISBURSEMENT', 'NSW Land Tax', FALSE, FALSE),
        ('FIRST_TITLE', 38, 'DISBURSEMENT', 'First Title', FALSE, FALSE),
        ('BALANCE_DEPOSIT', 39, 'SOURCE', 'Balance of Deposit', FALSE, FALSE),
        ('OTHER_BPAY', 40, 'DISBURSEMENT', 'Other (BPAY)', FALSE, FALSE),
        ('GST_WITHHOLDING_ATO', 41, 'DISBURSEMENT', 'GST Withholding - ATO Provided', FALSE, FALSE),
        ('QLD_LAND_TAX', 42, 'DISBURSEMENT', 'QLD Land Tax', FALSE, FALSE),
        ('WINDFALL_GAINS_TAX', 43, 'DISBURSEMENT', 'Property Clearance Certificate - Windfall Gains Tax', FALSE, FALSE),
        ('GOVERNMENT_FEES_NECDS', 44, 'DISBURSEMENT', 'Government Charges (NECDS)', FALSE, FALSE),
        ('GOVERNMENT_FEES_SRO', 45, 'DISBURSEMENT', 'Government Charges (State Integration)', FALSE, FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 0, '<NULL>', 'Unknown Settlement Category', FALSE, TRUE)
    ) v(enum_name, enum_value, settlement_category_type, description, is_account_bpay_lockable, is_default)
)
SELECT
    '2026-03-17 18:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,
    settlement_category_type,
    description,
    is_account_bpay_lockable,

    CASE WHEN enum_name IN ('OTHER_DISBURSEMENT', 'PROFESSIONAL_FEES_DISBURSEMENT', 'VENDORS_FUNDS_DISBURSEMENT', 'LOAN_PAYOUT_DISBURSEMENT')
         THEN TRUE ELSE FALSE END AS account_only_disbursement,
    CASE WHEN enum_name IN ('BODYCORPORATE_FEES_DISBURSEMENT', 'COUNCIL_RATES_DISBURSEMENT', 'THIRD_PARTY_BENEFICIARY_DISBURSEMENT', 'WATER_RATES_DISBURSEMENT')
         THEN TRUE ELSE FALSE END AS account_or_bpay_disbursement,
    CASE WHEN enum_name IN ('OTHER_BPAY')
         THEN TRUE ELSE FALSE END AS bpay_only_disbursement,
    CASE WHEN enum_name IN ('GOVERNMENT_FEES_NECDS', 'GOVERNMENT_FEES_SRO')
         THEN TRUE ELSE FALSE END AS is_government_fee
FROM enum
