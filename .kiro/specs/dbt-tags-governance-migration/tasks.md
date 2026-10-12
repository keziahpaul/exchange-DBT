# Implementation Plan: dbt-tags Governance Migration

## Overview

Migrate the PEXA Exchange Data Platform from legacy PI tagging (`pi_*` / `PI_*`) to the new dbt-tags 1.9.0+ governance format (`secure_field=VALUE` / `variant_mask=TRAVERSE_VALUE_MASK`). Scope: entire repository across all layers (Raw, Stage, Curate, Data Services). All changes are configuration/metadata-only — no SQL model logic changes. The `+pre-hook` for tag removal and `+post-hook` for tag application are at the project level.

## Tasks

- [x] 1. Verify dbt-tags package version and add governance variables
  - [x] 1.1 Verify dbt-tags 1.9.0+ availability via Common_Lib and update packages.yml if needed
    - Check if `pexa-one-data-au-dbt-common-lib` provides dbt-tags >= 1.9.0
    - If not, add direct dependency `dbt-labs/dbt_tags` version `[">=1.9.0", "<2.0.0"]` to `packages.yml`
    - _Requirements: 1.1, 1.2, 1.3_

  - [x] 1.2 Add dbt-tags governance variables to `dbt_project.yml`
    - Add `dbt_tags__opt_in_default_naming_config: false` to the `vars:` block
    - Add `dbt_tags__allowed_tags: ["secure_field", "variant_mask"]` to the `vars:` block
    - Add `dbt_tags__tag_name_separator: "="` to the `vars:` block
    - Preserve existing `dbt_tags__database`, `dbt_tags__schema`, and `dbt_tags__resource_types` variables unchanged
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 2. Migrate column-level tags in stage/projects (completed)
  - [x] 2.1 Convert all legacy `pi_*` column tags in `models/stage/projects/stg_projects_tests.yml`
    - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.6_

- [x] 3. Remove legacy model-level tags and configure project-level hooks
  - [x] 3.1 Remove `+tags` list under `data_services.exchange` in `dbt_project.yml`
    - _Requirements: 4.1, 4.2, 4.3_
  - [x] 3.2 Move `+pre-hook` (STRIP_COLUMN_TAGS) to project level in `dbt_project.yml`
    - _Requirements: 5.1, 5.2, 5.3_

- [x] 4. Remove legacy masking policy macros
  - [x] 4.1 Remove all `create_masking_policy__*` macros from `macros/common_macros.sql`
    - _Requirements: 6.1_
  - [x] 4.2 Remove `create_additional_masking_policies_and_tags`, `tag_PI_table`, `apply_tags_to_source` macros
    - _Requirements: 6.2, 6.3, 6.4_
  - [x] 4.3 Delete `macros/apply_tags_on_views.sql`
    - _Requirements: 7.1_

- [x] 5. Migrate column-level tags across all remaining layers
  - [x] 5.1 Convert legacy tags in Raw layer YML files
    - `models/raw/api_logs/api_logs.yml`
    - `models/raw/api_logs/raw_sources.yml`
    - `models/raw/exchange/exchange_external_tables.yml`
    - `models/raw/exchange/mat_views/raw_exchange_matviews.yml`
    - `models/raw/pexakey/pexakey.yml`
    - `models/raw/projects/projects_external_tables.yml`
    - Apply same mapping: `pi_multi` → `secure_field=PI_MULTI` + `variant_mask=TRAVERSE_VALUE_MASK`; all others → `secure_field=PI_<TYPE>`
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 5.2 Convert legacy tags in Stage layer YML files
    - `models/stage/exchange/stg_tests.yml`
    - (`models/stage/projects/stg_projects_tests.yml` already done in task 2.1)
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 5.3 Convert legacy tags in Curate layer YML files
    - `models/curate/api_logs/api_logs_curate_views.yml`
    - `models/curate/exchange/exchange_curate.yml`
    - `models/curate/pexakey/curate_pexakey.yml`
    - `models/curate/projects/projects_curate.yml`
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 5.4 Convert legacy tags in Data Services layer YML files
    - `models/data_services/api_logs/api_logs_data_services.yml`
    - `models/data_services/api_push_notification/current/ds_api_push_notification.yml`
    - `models/data_services/exchange/active/ds_exchange_views.yml`
    - `models/data_services/exchange/exchange_data_services.yml`
    - `models/data_services/pexakey/dataservices_pexakey.yml`
    - `models/data_services/projects/projects_data_services.yml`
    - _Requirements: 3.1, 3.2, 3.3_

- [x] 6. Audit tag consistency across lineage layers
  - [x] 6.1 Compare tags between data_services and stage/curate layers
    - If data_services has PI tags on columns that are missing in stage or curate, add the missing tags
    - If stage/curate has PI tags missing from data_services _hist models, add the missing tags
    - Ensure tag counts match across lineage for each model chain
    - _Requirements: 3.7_
    - **Fixes applied:**
    - Stage/Curate projects: added `secure_field=PI_MULTI` + `variant_mask=TRAVERSE_VALUE_MASK` on `data` column for `stg_batch_report_item`, `batch_report_item`, `stg_configuration`, `configuration`
    - DS exchange _hist: added 51 missing tags across 15 _hist models to match active counterparts (`vw_corrective_payments_hist` +24, `vw_project_supplier_hist` +7, `vw_notice_of_sales_hist` +3, `vw_mobile_signing_status_hist` +3, etc.)
    - `vw_event_audit_entry` has no _hist model — 1 tag difference is expected and acceptable

- [x] 7. Run validation and final checkpoint
  - [x] 7.1 confirm zero legacy tags remain
    - _Requirements: 8.1, 8.2, 8.3_
  - [x] 7.2 Verify YAML files parse correctly after all changes
  - [x] 7.3 Verify `dbt compile` succeeds
    - _Requirements: 10.1_

## Notes

- Tasks 1-4 are already completed from the initial phase (stage/projects scope)
- Tasks 5-7 extend the migration to the entire repository
- All changes are configuration/metadata-only — no SQL model logic is modified
- The `+pre-hook` (STRIP_COLUMN_TAGS) and `+post-hook` (apply_column_tags) are at the project level
- Tag mapping: `pi_multi` → `secure_field=PI_MULTI` + `variant_mask=TRAVERSE_VALUE_MASK`; all others → `secure_field=PI_<TYPE>`
