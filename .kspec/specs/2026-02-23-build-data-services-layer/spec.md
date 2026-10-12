# Build Data Services Layer

**JIRA**: DD-5638  
**Created**: 2026-02-23T14:29:34+11:00  
**Status**: Completed

## Overview
Build analytics-ready data services layer on top of the curated DAI tables, following established patterns for business intelligence and reporting use cases.

## Requirements

### Data Services Layer
- Create analytics-ready marts from DAI curate models
- Implement business logic aggregations and calculations
- Apply dimensional modeling principles where appropriate
- Ensure PI compliance with proper masking policies
- Configure optimized materialization strategies

### Target Models
Build data services for specific DAI entities:
- **vw_residual_configs**: Residual configuration management
- **vw_residuals**: Residual processing data with PI governance
- **vw_correspondences**: Correspondence activity with comprehensive PI masking
- **vw_subscriber_correspondence**: Subscriber correspondence relationships
- **vw_conversations_read_ref**: Conversation read tracking
- **vw_simultaneous_workspaces**: Simultaneous lodgement workspace relationships
- **vw_simultaneous_lodgements**: Simultaneous lodgement workflow management

### Technical Specifications
- Follow existing data_services naming conventions
- Use appropriate materialization (table/view based on usage)
- Implement incremental refresh where beneficial
- Add comprehensive documentation and column descriptions
- Configure proper database/schema routing per environment

## Acceptance Criteria
- [x] Data services models created for key DAI entities (7 views completed)
- [x] Models follow established patterns from existing data_services
- [x] PI compliance maintained with appropriate masking
- [x] Performance optimized with proper materialization
- [x] Comprehensive testing and documentation added
- [x] Historical views created for complete data lineage
- [x] Models deploy successfully across all environments

## Implementation Notes
- Leverage existing patterns from data_services/exchange, projects
- Focus on business value and analytical use cases
- Ensure transient table configuration for non-production
- Add models to appropriate dbt_project.yml configuration sections
