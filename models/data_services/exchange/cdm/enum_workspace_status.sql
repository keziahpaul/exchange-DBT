{{
    config(
        materialized = 'ephemeral'
    )
}}
{#- sourced from core-pexa-app/pexa_core/src/main/java/au/necdl/pexa/core/workspace/WorkspaceStatus.java @release/R.23.01.00 -#}
{#- If you change the structure of this model, you need to update value of the created_on column -#}

WITH enum AS (
    SELECT enum_name, enum_value, lodgement_name, settlement_name, is_default
    FROM (VALUES
        ('IN_PREPARATION', 'In Preparation', 'IN_PREPARATION', NULL, FALSE),
        ('PREPARED', 'Prepared', 'PREPARED', NULL, FALSE),
        ('READY', 'Ready', 'READY', NULL, FALSE),
        ('LODGING', 'Lodging', 'LODGING', NULL, FALSE),
        ('LODGED', 'Lodged', 'LODGED', NULL, FALSE),
        ('ABANDONED', 'Abandoned', NULL, NULL, FALSE),
        ('CLOSED', 'Completed', 'CLOSED', NULL, FALSE),
        ('SETTLING', 'Settling', 'READY', 'SETTLING', FALSE),
        ('SETTLED', 'Settled', 'READY', 'SETTLED', FALSE),
        ('DISBURSING', 'Disbursing', 'READY', 'DISBURSING', FALSE),
        ('DISBURSED', 'Disbursed', 'READY', 'DISBURSED', FALSE),
        ('SETTLING_AND_LODGING', 'Lodging & Settling', 'LODGING', 'SETTLING', FALSE),
        ('SETTLING_AND_LODGED', 'Lodged & Settling', 'LODGED', 'SETTLING', FALSE),
        ('SETTLED_AND_LODGED', 'Lodged & Settled', 'LODGED', 'SETTLED', FALSE),
        ('SETTLED_AND_LODGING', 'Lodging & Settled', 'LODGING', 'SETTLED', FALSE),
        ('DISBURSING_LODGED', 'Lodged & Disbursing', 'LODGED', 'DISBURSING', FALSE),
        ('DISBURSING_LODGING', 'Lodging & Disbursing', 'LODGING', 'DISBURSING', FALSE),
        ('DISBURSED_LODGING', 'Lodging & Disbursed', 'LODGING', 'DISBURSED', FALSE),
        ('LOCKED_SQ_SETTLEMENT', 'Locked (Sequential Settlement)', 'READY', 'LOCKED', FALSE),
        ('SETTLEMENT_HELD', 'Settlement Held', NULL, NULL, FALSE),
        ('LODGED_DISBURSED', 'Lodged & Disbursed', 'LODGED', 'DISBURSED', FALSE),
        ('COMPLETED_SETTLED', 'Completed & Settled', 'CLOSED', 'SETTLED', FALSE),
        ('COMPLETED_DISBURSED', 'Completed & Disbursed', 'CLOSED', 'DISBURSED', FALSE),
        ('COMPLETED_SETTLING', 'Completed & Settling', 'CLOSED', 'SETTLING', FALSE),
        ('COMPLETED_DISBURSING', 'Completed & Disbursing', 'CLOSED', 'DISBURSING', FALSE),
        ('NOT_ACCEPTED_STTLNG', 'Not Accepted & Settling', 'NOT_ACCEPTED', 'SETTLING', FALSE),
        ('NOT_ACCEPTED_SETTLED', 'Not Accepted & Settled', 'NOT_ACCEPTED', 'SETTLED', FALSE),
        ('NOT_ACCEPTED_DSBRSNG', 'Not Accepted & Disbursing', 'NOT_ACCEPTED', 'DISBURSING', FALSE),
        ('NOT_ACCEPTED_DSBRSD', 'Not Accepted & Disbursed', 'NOT_ACCEPTED', 'DISBURSED', FALSE),
        ('FAILED', 'FAILED', NULL, NULL, FALSE),
        {#- appended for NULL values #}
        ('<NULL>', 'Unknown Workspace Status', NULL, NULL, TRUE)
    ) v(enum_name, enum_value, lodgement_name, settlement_name, is_default)
)
SELECT
    '2026-03-09 18:30:00 +10'::timestamp_tz AS created_on,
    is_default,

    enum_name,
    enum_value,
    lodgement_name,
    settlement_name,

    {#- one of these generated fields are meaningless when enum_name is '<NULL>' #}
    CASE WHEN enum_name NOT IN ('IN_PREPARATION', 'PREPARED', 'READY')
         THEN TRUE ELSE FALSE END AS locked,
    CASE WHEN enum_name != 'ABANDONED'
         THEN TRUE ELSE FALSE END AS not_abandoned,
    CASE WHEN enum_name NOT IN ('ABANDONED', 'COMPLETED_DISBURSING')
         THEN TRUE ELSE FALSE END AS active,
    CASE WHEN enum_name IN (
        'COMPLETED_SETTLING', 'COMPLETED_DISBURSING', 'DISBURSING_LODGED', 'DISBURSING_LODGING',
        'LOCKED_SQ_SETTLEMENT', 'NOT_ACCEPTED_DSBRSNG', 'NOT_ACCEPTED_SETTLED', 'NOT_ACCEPTED_STTLNG',
        'SETTLED_AND_LODGED', 'SETTLED_AND_LODGING', 'SETTLING', 'SETTLING_AND_LODGED'
    )
         THEN TRUE ELSE FALSE END AS in_progress,
    CASE WHEN enum_name IN ('IN_PREPARATION', 'PREPARED')
         THEN TRUE ELSE FALSE END AS in_prep,
    CASE WHEN enum_name NOT IN (
        'READY', 'LODGING', 'LODGED', 'ABANDONED', 'CLOSED', 'SETTLED', 'SETTLED_AND_LODGED', 'SETTLED_AND_LODGING',
        'LOCKED_SQ_SETTLEMENT', 'COMPLETED_SETTLED', 'COMPLETED_SETTLING', 'NOT_ACCEPTED_STTLNG', 'NOT_ACCEPTED_SETTLED', 'FAILED'
    )
         THEN TRUE ELSE FALSE END AS sett_trans_dashboard_status,
    CASE WHEN enum_name IN (
        'READY', 'LODGING', 'LODGED', 'CLOSED', 'SETTLING', 'SETTLED', 'DISBURSING', 'DISBURSED', 'SETTLING_AND_LODGING',
        'SETTLING_AND_LODGED', 'SETTLED_AND_LODGED', 'SETTLED_AND_LODGING', 'DISBURSING_LODGED', 'DISBURSING_LODGING',
        'DISBURSED_LODGING', 'SETTLEMENT_HELD', 'LODGED_DISBURSED', 'COMPLETED_SETTLED', 'COMPLETED_DISBURSED',
        'COMPLETED_SETTLING', 'COMPLETED_DISBURSING', 'NOT_ACCEPTED_STTLNG', 'NOT_ACCEPTED_SETTLED',
        'NOT_ACCEPTED_DSBRSNG', 'NOT_ACCEPTED_DSBRSD', 'LOCKED_SQ_SETTLEMENT'
    )
         THEN TRUE ELSE FALSE END AS ready
FROM enum
