# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning.

## [2.0] 2024-08-14

### Fixed

- Updating the .gitignore to include the package-lock.yml in dbt and manually removing the packages as they'll be installed by the dbt deps command as part of the jobs.

### New

- Added RAW, CURATE and DATA SERVICES models for API Logs


### Updated

- Updated dbt_project.yml to include the relevant database/ schema information for API Logs.
- Removing the severity: warn from all of the Exchange & Projects tests as this is now taken care of by the dbt_project.yml default which is set to warn.


## [1.2] 2024-07-18

### Fixed

- Fix column_count_check tests for pexa_projects.workspace.modified_by_ip in curated layer

### New

- Added Historical and Active views for PEXA Projects in Data Servicers layer


### Updated

- Split `raw_sources.yml` and `curate_views.yml` into each own source folder. This is another abstraction aimed for easier maintanability and isolation.

- For PEXA Projects models if columns are tagged PI_MULTI do not promote them into curate layer as there are no requirement or use case for these columns


## [1.1] 2024-07-12

### New

- Added Historical and Active views for Exchange Data in Data Services layer

- Add PEXA Projects raw to curate models materialized as views with pi tags and masking applied. Models are 1:1 no transformations applied

- Added new PI_MULTI tag

- Added new PI_MULTI masking policy (JSON_MASK_UDF) - used to mask JSONB/Variant column types as these contain json/nested json key/pairs that may contain PI. The mask is generic compared to the other columns due to JSON_MASK_UDF not having the smarts to mask based on tag.

**Misc**
- Added new helper script `bulk-rename-files.py` this is super handy for bulk renaming model files. Particular helping when naming historical and active files

- Added new helper script `append-after-string.py` this was helpful when trying to add a `where` clause for active views

### Updated

- Abstract sources by different folders to better separate logic and keep model files modular and concise.
    - `models/curate/exchange`
    - `models/curate/projects`
    - `models/data_services/exchange`
    - `models/data_services/projects`

- `column_count_check` macro now accepts two additional params (source_exclude, model_exclude). Gives the option of excluding certain fields from the test, in certain models we do not promote or carry over a given particular field therefore the source column count vs target column count will never match.


## [1.0] 2024-05-20

### New

- Add raw to curate models for Exchange data with data masks applied. Models are 1:1 no transformations

- Add data services models for Exchange data that will be shared via Private Data Share into Snowflake Group Account (INBOUNRD_DATA_SERVICES DB)

- Add logging functionality; Logs are vital for DevSecOps ensuring we have full traceability across all the operations of fivetran, dbt and snowflake

    - **Fivetran logs:** account, connector_type, connector, destination, incremental_mar, log, resource_membership, role_permission, role, team_membership, team, usage_cost and user

    - **Dbt logs:** dim_dbt__current_models, dim_dbt__models, dim_dbt__seeds, dim_dbt__sources, dim_dbt__tests, dim_dbt__inocations, dim_dbt__model_executions, dim_dbt__seed_executions, dim_dbt__test_executions

    - **snowflake logs:** access_history, aggregate_access_history, data_transfer_history, grants_to_roles, login_history, policy_references, query_history, tag_references, users
