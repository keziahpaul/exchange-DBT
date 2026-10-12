# Technology Stack

## Languages & Runtime
- **SQL/Jinja**: Primary transformation language (dbt models)
- **Python 3.x**: Helper scripts and automation tools
- **YAML**: Configuration and documentation

## Frameworks & Platforms
- **dbt Core**: Data transformation framework with custom materializations
- **Snowflake**: Cloud data warehouse with external tables and materialized views
- **dbt Cloud**: Development and orchestration environment

## Key Libraries & Packages
- **Snowflake-Labs/dbt_constraints** (0.6.x): Data validation and constraints
- **metaplane/dbt_expectations** (0.10.8): Advanced data quality testing
- **brooklyn-data/dbt_artifacts** (2.9.3): Metadata and lineage tracking
- **dbt-labs/dbt_external_tables** (0.11.1): External data source integration
- **dbt-labs/codegen** (0.12.1): Code generation utilities
- **pexa-one-data-au-dbt-common-lib**: Internal shared macros (git-based)

## Tools & Infrastructure
- **SQLFluff**: SQL linting and formatting
- **GitHub**: Version control and CI/CD with Dependabot
- **dbt Cloud IDE**: Development environment
- **Custom Generic Tests**: 15+ data quality validation macros

## Architecture Patterns
- **Medallion Architecture**: Raw (120+ models) → Stage (36+ models) → Curate (119+ models) → Data Services (37+ models)
- **SCD2 Materializations**: Custom `scd_materialization` with `scd2_transformation` strategy
- **Incremental Processing**: Append and merge strategies with delta column tracking
- **Environment Isolation**: 5-environment deployment (DEV/STG/TEST/PST/PRD)
- **PI Governance**: Automated tagging with `dbt_tags.apply_column_tags()` post-hook