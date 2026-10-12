# DAI Raw and Curate Build - Tasks

**JIRA**: DD-5637  
**Generated**: 2026-02-12T13:24:06+11:00

## Raw Layer Tasks

### Task 1: Create DAI External Tables Configuration
- [ ] Create external table definitions for all 15 DAI tables
- [ ] Configure Snowflake external table sources
- [ ] Add to `models/raw/exchange/exchange_external_tables.yml`
- [ ] Test external table connectivity

### Task 2: Implement DAI Raw Materialized Views
- [x] Create materialized views for all 15 DAI tables in `models/raw/exchange/mat_views/`
- [x] Follow naming convention: `vw_pxa_[table_name]` (matching existing pattern)
- [x] Configure materialized_view_snowflake materialization
- [x] Add environment-specific schema configuration

## Stage Layer Tasks

### Task 3: Create DAI Stage Models
- [x] Implement stage models for all 15 DAI tables in `models/stage/exchange/`
- [x] Follow naming convention: `stg_pxa_[table_name]`
- [x] Follow existing stage table patterns for exchange (reference raw views, incremental logic, delete tracking, primary key lookups)
- [x] Configure incremental materialization with append strategy
- [x] Add data type standardization transformations
- [x] Update `stg_tests.yml` to include data mapping information (data type, description, PI masking) following existing pattern in file

### Task 4: Apply PI Tagging to Stage Models
- [x] Add PI tags for pxa_correspondences (PI_NAME, PI_EMAIL, PI_CONTACT_NUMBER, etc.)
- [x] Add PI tags for pxa_line_items_changelog (PI_SENSITIVE_FINANCIAL)
- [x] Add PI tags for pxa_document_counterpart (PI_FREE_TEXT_FIELD)
- [x] Add PI tags for pxa_residuals (PI_MULTI)

## Curate Layer Tasks

### Task 6: Create DAI Curate Models
- [x] Implement curate models for all 15 DAI tables in `models/curate/exchange/`
- [x] Follow naming convention: `pxa_[table_name]` (matching existing pattern)
- [x] Replicate existing curate table patterns (consistent columns, SCD2 structure)
- [x] Include all columns from data-mapping.md specifications
- [x] Configure SCD2 materialization with scd2_transformation strategy
- [x] Add business logic and data standardization

### Task 7: Configure SCD2 Transformations
- [x] Set primary keys using var('primary_keys_dict')
- [x] Configure source_delta_column and target_delta_column
- [x] Set up effective date columns and handle_deletes
- [x] Add SCD2-specific configuration parameters
- [x] Update exchange_curate.yml for each table matching existing patterns
- [x] Add PI masking and descriptions to columns matching the stage yaml info

### Task 8: Apply PI Compliance to Curate Layer
- [x] Ensure PI masking policies are applied
- [x] Configure secure materialization for sensitive tables
- [x] Add PI compliance pre-hooks
- [x] Validate PI tag inheritance from stage layer

### Task 9: Add Curate Layer Data Quality Tests
- [x] Implement SCD2 integrity checks (active row validation)
- [x] Add record effectiveness overlap detection
- [x] Configure historical data validation tests
- [x] Add comprehensive data quality test suite

## Configuration Tasks

### Task 10: Update dbt_project.yml
- [x] Add DAI models to appropriate configuration sections
- [x] Configure database/schema routing for all environments
- [x] Set transient table configuration for non-production
- [x] Add DAI-specific materialization settings

### Task 11: Add Primary Key Mappings
- [x] Add all 15 DAI tables to primary_keys_dict in dbt_project.yml
- [x] Verify primary key definitions match data mapping
- [x] Test primary key configurations across all models

## Documentation Tasks

### Task 12: Model Documentation
- [x] Add model descriptions for all DAI tables
- [x] Document column descriptions and PI classifications
- [x] Update model YAML files with comprehensive metadata
- [x] Ensure documentation reflects data-mapping.md specifications

### Task 13: Testing and Validation
- [x] Run full dbt build on all DAI models
- [x] Validate data quality test pass rates >99%
- [x] Test deployment across all environments (DEV/STG/TEST/PST/PRD)
- [x] Verify PI compliance and masking policies

## Acceptance Criteria Validation
- [x] All 15 DAI tables implemented in raw, stage, and curate layers
- [x] SCD2 pattern correctly implemented for historical tracking
- [x] PI tags applied according to data-mapping.md specifications
- [x] Data quality tests achieve >99% success rate
- [x] Models deploy successfully across all environments
- [x] Documentation updated and comprehensive
