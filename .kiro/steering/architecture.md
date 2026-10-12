# Architecture & Patterns

## Data Architecture
- **Medallion Pattern**: Bronze (Raw) → Silver (Stage) → Gold (Curate) → Platinum (Data Services)
- **Layer Responsibilities**:
  - Raw: External tables, minimal transformation
  - Stage: Incremental processing, data type standardization
  - Curate: SCD2 transformations, business logic application
  - Data Services: Analytics-ready marts with PI governance

## Data Governance
- **PI Tagging**: Automated classification of personal information
- **Masking Policies**: Dynamic data masking based on user roles
- **Access Control**: Role-based permissions via Snowflake RBAC
- **Audit Trail**: Complete lineage tracking via dbt artifacts

## Performance Patterns
- **Incremental Models**: Append-only strategy for large datasets
- **Materialized Views**: Snowflake-native optimization for raw layer
- **Clustering**: Strategic clustering keys for query performance
- **Transient Tables**: Non-production environments use transient storage

## Environment Strategy
- **Isolation**: Separate databases per environment
- **Promotion**: Feature → Develop → Release → Main branch flow
- **Configuration**: Environment-specific variables via dbt Cloud
- **Testing**: Isolated CI schemas for pull request validation
