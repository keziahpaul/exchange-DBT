# PEXAKey Support Handover

## Source History & Architectural Changes

### Property Settlement — Decommissioned (DynamoDB → RDS)

The `ms_api_property_settlement` DynamoDB-sourced microservice table was
**decommissioned** and transitioned to an **RDS instance**.

It is now replaced by **5 RDS tables**, ingested via a **stored procedure**:

- `address`
- `task`
- `subscriber`
- `tracking_user`
- `tracking`

These are surfaced through the `rds_*` curate models
(`rds_address`, `rds_task`, `rds_subscriber`, `rds_tracking_user`,
`rds_tracking`). The legacy `ms_api_property_settlement` raw table /
`vw_property_settlement` view is retained for historical reference only.

### DynamoDB Source Location Changes (new `sot-` prefix)

The following DynamoDB instances were changed, and the S3 source location was
updated to a new `sot-` prefix in the **same bucket**. The DynamoDB Streams
define the S3 prefix, which matches the DynamoDB table name.

| Table | Old prefix | New prefix |
|-------|------------|------------|
| `ms_api_bank_account_store` | `ms-api-bank-account-store-ms-prd/` | `prd-sot-ms-api-bank-account-store/` |
| `ms_api_property_store` | (previous `-ms-prd` prefix) | `prd-sot-ms-api-property-store/` |
| `web_app_registration_ms` | (previous `-ms-prd` prefix) | `prd-sot-web-app-registration/` |

Note: `sot-` is a new prefix within the same bucket. Because the DynamoDB
Streams define the S3 prefix using the DynamoDB table name, the new prefix
mirrors the table name under the `sot-` namespace.
