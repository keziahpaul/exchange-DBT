{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/workspace/WorkspaceRoleEnum.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, workspace_role_name, workspace_role_shortname, workspace_role_acronym, is_default
    FROM (VALUES
        ('MORTGAGEE_ON_TITLE', 1, 'Mortgagee on Title', 'MoT', 'MoT', FALSE),
        ('INCOMING_PROPRIETOR', 2, 'Incoming Proprietor', 'IP', 'IP', FALSE),
        ('INCOMING_CAVEATOR', 3, 'Incoming Caveator', 'ICAV', 'IC', FALSE),
        ('PROPRIETOR_ON_TITLE', 4, 'Proprietor on Title', 'PoT', 'PoT', FALSE),
        ('INCOMING_MORTGAGEE', 5, 'Incoming Mortgagee', 'IM', 'IM', FALSE),
        ('CAVEATOR_ON_TITLE', 6, 'Caveator on Title', 'CAVoT', 'CoT', FALSE),
        ('CAVEATOR', 7, 'Caveator', 'CAV', 'CAV', FALSE),
        ('CONSENTER', 8, 'Consentor', 'CON', 'CNS', FALSE),
        ('CT_CONTROLLER', 9, 'CT Controller', 'CT', 'CTC', FALSE),
        ('INCOMING_CHARGEE', 10, 'Incoming Chargee', 'ICh', 'ICH', FALSE),
        ('CHARGEE_ON_TITLE', 11, 'Chargee on Title', 'ChoT', 'CHG', FALSE),
        ('APPLICANT', 12, 'Applicant', 'App', 'APL', FALSE),
        ('SOURCE_FUNDER', 13, 'Source Funder', 'SF', 'SF', FALSE),
        ('ENCUMBRANCEE_ON_TITLE', 14, 'Encumbrancee on Title', 'EoT', 'EoT', FALSE),
        ('INCOMING_ENCUMBRANCEE', 15, 'Incoming Encumbrancee', 'IE', 'IE', FALSE),
        ('INTEREST_HOLDER', 16, 'Interest Holder', 'IH', 'IH', FALSE),
        ('TO_DEAL_WITH_AN_INTEREST', 17, 'To deal with an Interest', 'TDI', 'TDI', FALSE),
        {#- appended for NULL values #}
        ('<NULL>', -1, 'Unknown Workspace Status', NULL, NULL, TRUE)
    ) v(enum_name, enum_value, workspace_role_name, workspace_role_shortname, workspace_role_acronym, is_default)
)
SELECT
    '2026-03-09 18:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,
    workspace_role_name,
    workspace_role_shortname,
    workspace_role_acronym,

    {#- one of these generated fields are meaningless when enum_name is '<NULL>' #}
    CASE WHEN enum_name IN ('INCOMING_PROPRIETOR', 'PROPRIETOR_ON_TITLE')
         THEN TRUE ELSE FALSE END AS accepted_roles_gst,
    CASE WHEN enum_name IN ('APPLICANT', 'CAVEATOR_ON_TITLE', 'CHARGEE_ON_TITLE', 'CONSENTER', 'CT_CONTROLLER', 'ENCUMBRANCEE_ON_TITLE',
        'INCOMING_CAVEATOR', 'INCOMING_CHARGEE', 'INCOMING_ENCUMBRANCEE', 'INCOMING_MORTGAGEE', 'INCOMING_PROPRIETOR', 'MORTGAGEE_ON_TITLE',
        'PROPRIETOR_ON_TITLE', 'TO_DEAL_WITH_AN_INTEREST')
         THEN TRUE ELSE FALSE END AS accepted_roles_domain_api,
    CASE WHEN enum_name IN ('INCOMING_MORTGAGEE', 'INCOMING_PROPRIETOR', 'INCOMING_CAVEATOR', 'MORTGAGEE_ON_TITLE', 'CAVEATOR_ON_TITLE',
        'PROPRIETOR_ON_TITLE', 'APPLICANT')
         THEN TRUE ELSE FALSE END AS withdrawal_allowed_roles,
    CASE WHEN enum_name IN ('INCOMING_PROPRIETOR', 'PROPRIETOR_ON_TITLE', 'INCOMING_MORTGAGEE', 'MORTGAGEE_ON_TITLE')
         THEN TRUE ELSE FALSE END AS join_allowed_roles
FROM enum
