# DAI Raw and Curate Build

**JIRA**: DD-5637  
**Created**: 2026-02-12T13:15:29+11:00  
**Status**: Draft

## Overview
Build DAI (Data Analytics Infrastructure) raw and curate layers for the PEXA Exchange data platform, following the established medallion architecture patterns.

## Data Mapping
Source data mapping available in: `/Users/alay/Downloads/exchange tables(Sheet1) (2).csv`

**Key DAI Tables to Implement:**
- pxa_batch_tac
- pxa_business_event_outbox  
- pxa_conversations_read_ref
- pxa_correspondences (high PI content)
- pxa_document_counterpart
- pxa_line_items_changelog (financial data)
- pxa_lodgement_billing_event
- pxa_residuals
- pxa_simultaneous_lodgements
- pxa_subscriber_correspondence
- pxa_event_log_type
- pxa_ext_event_sub_mapping
- pxa_external_business_event
- pxa_residual_configs
- pxa_simultaneous_workspaces

Detailed table schemas, data types, descriptions, and PI tags documented in: `data-mapping.md`

## Requirements

### Raw Layer
- Create external tables for DAI source data
- Implement materialized views for performance optimization
- Configure environment-specific schemas

### Stage Layer
- Implement incremental processing with append strategy
- Apply data type standardization and basic transformations
- Add PI tagging for sensitive data identification
- Configure source-to-target reconciliation tests

### Curate Layer  
- Implement SCD2 transformations for historical tracking
- Apply business logic and data standardization
- Ensure PI compliance with masking policies
- Add comprehensive data quality tests

### Technical Specifications
- Follow existing naming conventions (dai_* prefix)
- Use incremental materialization strategies
- Implement custom generic tests for data validation
- Configure proper database/schema routing per environment

## Acceptance Criteria
- [ ] Raw layer models created with external table configuration
- [ ] Curate layer models implement SCD2 pattern
- [ ] All models have appropriate PI tags applied
- [ ] Data quality tests pass with >99% success rate
- [ ] Models deploy successfully across all environments
- [ ] Documentation updated in dbt model files

## Implementation Notes
- Leverage existing macros from pexa-one-data-au-dbt-common-lib
- Follow established patterns from exchange and projects sources
- Ensure transient table configuration for non-production environments
- Add models to appropriate dbt_project.yml configuration sections
