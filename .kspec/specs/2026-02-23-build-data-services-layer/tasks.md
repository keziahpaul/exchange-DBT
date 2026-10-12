# Build Data Services Layer - Tasks

**JIRA**: DD-5638  
**Generated**: 2026-02-23T14:29:34+11:00

## Data Services Layer Tasks

### Task 1: Create DAI Data Services Views
- [x] Create `vw_residual_configs` from pxa_residual_configs
- [x] Create `vw_residuals` from pxa_residuals with PI_MULTI tags
- [x] Create `vw_correspondences` from pxa_correspondences with comprehensive PI masking
- [x] Create `vw_subscriber_correspondence` from pxa_subscriber_correspondence
- [x] Create `vw_conversations_read_ref` from pxa_conversations_read_ref
- [x] Create `vw_simultaneous_workspaces` from pxa_simultaneous_workspaces
- [x] Create `vw_simultaneous_lodgements` from pxa_simultaneous_lodgements

### Task 2: Create DAI Historical Data Services Views
- [x] Create `vw_residual_configs_hist` from pxa_residual_configs
- [x] Create `vw_residuals_hist` from pxa_residuals with PI tags
- [x] Create `vw_correspondences_hist` from pxa_correspondences with comprehensive PI masking
- [x] Create `vw_subscriber_correspondence_hist` from pxa_subscriber_correspondence
- [x] Create `vw_conversations_read_ref_hist` from pxa_conversations_read_ref
- [x] Create `vw_simultaneous_workspaces_hist` from pxa_simultaneous_workspaces
- [x] Create `vw_simultaneous_lodgements_hist` from pxa_simultaneous_lodgements

### Task 3: Configure PI Compliance and Performance
- [x] Remove pre-hooks from active views (not needed for data services layer)
- [x] Implement active records filter (effective_to = '9999-12-31') for active views
- [x] Follow existing data services patterns and naming conventions
- [x] Configure proper materialization as views for both active and historical

### Task 4: Add Documentation and Testing
- [x] Add comprehensive model and column documentation to ds_exchange_views.yml
- [x] Add comprehensive model and column documentation to exchange_data_services.yml for historical views
- [x] Include PI tag classifications for sensitive columns (PI_MULTI, PI_FREE_TEXT_FIELD, PI_CONTACT_NUMBER, PI_EMAIL, PI_NAME, etc.)
- [x] Document data types and descriptions for all columns
- [x] Add missing SCD2 columns (effective_from, effective_to, inserted_at, updated_at)
- [x] Follow established YAML documentation patterns

### Task 5: Create Feature Branch and Version Control
- [x] Create feature branch `feature/DD-5638-data-service-build`
- [x] Commit all changes with comprehensive commit message
- [x] Update spec and tasks to reflect completed work

## Acceptance Criteria Validation
- [x] All data services models follow established patterns
- [x] PI compliance maintained with appropriate masking
- [x] Performance optimized with proper materialization
- [x] Comprehensive testing and documentation completed
- [x] Historical views created for complete data lineage
- [x] Models deploy successfully across all environments
