# Requirements Document

## Introduction

This specification covers the migration of the PEXA Exchange Data Platform dbt project from the legacy PI tagging format (e.g. `pi_full_name`) to the new dbt-tags governance tag format introduced in dbt-tags 1.9.0+. The new format uses two allowed tags (`secure_field` and `variant_mask`) with an equals-sign separator and UPPER CASE values (e.g. `secure_field=PI_FULL_NAME`). The migration spans all layers of the Medallion Architecture (Raw, Stage, Curate, Data Services), removes legacy masking policy macros, replaces legacy `pre_sql` tag-removal hooks, and adds a new `pre_sql` stored procedure call for tag removal on all masked models.

## Glossary

- **Migration_Tool**: The dbt project build and configuration system used to apply the dbt-tags governance migration changes
- **dbt_project_config**: The `dbt_project.yml` file that defines project-level variables, hooks, and model configurations
- **Model_YML**: Any `.yml` file under the `models/` directory that defines column-level metadata including tags
- **Legacy_Tag**: A PI tag in the old format using lowercase with `pi_` prefix (e.g. `pi_full_name`, `pi_email`, `pi_sensitive_financial`)
- **New_Tag**: A governance tag in the new format using an allowed tag name, equals separator, and UPPER CASE value (e.g. `secure_field=PI_FULL_NAME`, `variant_mask=PI_MULTI`)
- **Allowed_Tags**: The two permitted tag names in the new governance format: `secure_field` and `variant_mask`
- **Tag_Name_Separator**: The equals sign (`=`) character used to separate the tag name from the tag value in the new format
- **Masking_Policy_Macro**: A macro in `common_macros.sql` that delegates to `pexa_one_data_au_dbt_common_lib` to create Snowflake masking policies (e.g. `create_masking_policy__pi_email`)
- **Tag_Removal_Stored_Procedure**: A new Snowflake stored procedure that removes stale tags from models before new tags are applied
- **Post_Hook**: The existing `dbt_tags.apply_column_tags()` post-hook that applies column-level tags after model materialisation
- **Common_Lib**: The internal `pexa-one-data-au-dbt-common-lib` git-based dbt package providing shared macros
- **PI_Tag_Types**: The 14 distinct PI classification types used in this project: `pi_business_name`, `pi_contact_number`, `pi_dob`, `pi_email`, `pi_fax`, `pi_free_text_field`, `pi_full_address`, `pi_full_name`, `pi_multi`, `pi_name`, `pi_partial_address`, `pi_sensitive`, `pi_sensitive_financial`, `pi_userid`

## Requirements

### Requirement 1: Upgrade dbt-tags Package Version

**User Story:** As a data engineer, I want to ensure dbt-tags version 1.9.0 or higher is in use across the project, so that the new governance tag format is supported.

#### Acceptance Criteria

1. WHEN the dbt project dependencies are resolved, THE Migration_Tool SHALL use dbt-tags version 1.9.0 or higher
2. IF dbt-tags is provided transitively through the Common_Lib, THEN THE Migration_Tool SHALL verify the Common_Lib supplies dbt-tags 1.9.0 or higher
3. IF dbt-tags is not available at version 1.9.0 or higher through the Common_Lib, THEN THE Migration_Tool SHALL add a direct dbt-tags dependency at version 1.9.0 or higher to `packages.yml`

### Requirement 2: Configure dbt-tags Governance Variables

**User Story:** As a data engineer, I want to set the new dbt-tags governance variables in `dbt_project.yml`, so that the project enforces the new tag naming conventions.

#### Acceptance Criteria

1. THE dbt_project_config SHALL define the variable `dbt_tags__opt_in_default_naming_config` with value `false`
2. THE dbt_project_config SHALL define the variable `dbt_tags__allowed_tags` with value `["secure_field", "variant_mask"]`
3. THE dbt_project_config SHALL define the variable `dbt_tags__tag_name_separator` with value `"="`
4. WHEN the dbt project is compiled, THE dbt_project_config SHALL retain all existing `dbt_tags__database`, `dbt_tags__schema`, and `dbt_tags__resource_types` variable definitions unchanged

### Requirement 3: Migrate Column Tags to New Format

**User Story:** As a data engineer, I want all column-level PI tags converted from the legacy format to the new governance format, so that masking policies are applied correctly under the new system.

#### Acceptance Criteria

1. WHEN a column in a Model_YML has a Legacy_Tag of type `pi_multi`, THE Migration_Tool SHALL replace the tag with `variant_mask=PI_MULTI`
2. WHEN a column in a Model_YML has a Legacy_Tag of any PI_Tag_Type other than `pi_multi`, THE Migration_Tool SHALL replace the tag with `secure_field=<VALUE>` where `<VALUE>` is the legacy tag name without the `pi_` prefix, converted to UPPER CASE (e.g. `pi_email` becomes `secure_field=PI_EMAIL`, `pi_full_name` becomes `secure_field=PI_FULL_NAME`)
3. THE Migration_Tool SHALL apply the tag conversion to all Model_YML files across all layers: Raw, Stage, Curate, and Data Services
4. THE Migration_Tool SHALL preserve the tag name portion (`secure_field` or `variant_mask`) in lowercase as defined in the Allowed_Tags list
5. THE Migration_Tool SHALL format the tag value portion (after the equals sign) in UPPER CASE
6. WHEN a column has a tag defined at the column level using the `tags:` key directly under the column (not nested under `config:`), THE Migration_Tool SHALL migrate the tag in the same structural location

### Requirement 4: Migrate Model-Level Tags in dbt_project.yml

**User Story:** As a data engineer, I want the model-level `+tags` list in `dbt_project.yml` converted to the new format, so that data services layer tags are consistent with the new governance standard.

#### Acceptance Criteria

1. WHEN the dbt_project_config defines `+tags` with UPPER CASE Legacy_Tag values (e.g. `PI_BUSINESS_NAME`), THE Migration_Tool SHALL replace each tag with the corresponding New_Tag format (e.g. `secure_field=PI_BUSINESS_NAME`)
2. WHEN a model-level tag value matches `PI_MULTI`, THE Migration_Tool SHALL replace the tag with `variant_mask=PI_MULTI`
3. THE Migration_Tool SHALL preserve the `+tags` list structure and indentation in the dbt_project_config

### Requirement 5: Add Tag Removal Pre-SQL Hook

**User Story:** As a data engineer, I want a `+pre_sql` configuration added to execute the tag removal stored procedure before tag application, so that stale tags from previous runs are cleaned up.

#### Acceptance Criteria

1. THE dbt_project_config SHALL define a `+pre_sql` configuration that executes the Tag_Removal_Stored_Procedure for all models that have masking tags applied
2. WHEN a model is built, THE Migration_Tool SHALL execute the Tag_Removal_Stored_Procedure before the Post_Hook applies new tags
3. THE dbt_project_config SHALL apply the `+pre_sql` at the project level to cover all models with masking across all layers

### Requirement 6: Remove Legacy Pre-SQL Tag Configurations

**User Story:** As a data engineer, I want all pre-existing `pre_sql` configurations that altered tags to be removed, so that the legacy tag manipulation logic does not conflict with the new governance system.

#### Acceptance Criteria

1. WHEN a model or model group in the dbt_project_config has a `pre_sql` or `+pre-hook` configuration that references tag alteration or tag removal, THE Migration_Tool SHALL remove that configuration
2. THE Migration_Tool SHALL preserve all `pre_sql` and `+pre-hook` configurations that are unrelated to tag management (e.g. `ALTER SESSION SET TIMEZONE`)

### Requirement 7: Remove Legacy Masking Policy Macros

**User Story:** As a data engineer, I want all legacy masking policy creation macros removed from the project, so that the codebase does not contain unused governance code.

#### Acceptance Criteria

1. THE Migration_Tool SHALL remove all `create_masking_policy__*` macro definitions from `macros/common_macros.sql` (covering all 14 PI types: `pi_sensitive_financial`, `pi_full_address`, `pi_partial_address`, `pi_business_name`, `pi_name`, `pi_full_name`, `pi_sensitive`, `pi_contact_number`, `pi_fax`, `pi_free_text_field`, `pi_flag_sensitive`, `pi_userid`, `pi_dob`, `pi_email`, `pi_multi`)
2. THE Migration_Tool SHALL remove the `create_additional_masking_policies_and_tags` macro from `macros/common_macros.sql`
3. THE Migration_Tool SHALL remove the `tag_PI_table` macro from `macros/common_macros.sql`
4. THE Migration_Tool SHALL remove the `apply_tags_to_source` macro from `macros/common_macros.sql`
5. THE Migration_Tool SHALL preserve all non-masking macros in `macros/common_macros.sql` (e.g. `generate_schema_name`, `column_count_check`, `materialized_view`, `stored_proc`, `is_newer`, logging macros)

### Requirement 8: Remove or Update apply_tags_on_views Macro

**User Story:** As a data engineer, I want the `apply_tags_on_views` macro updated or removed to be compatible with the new tag format, so that view-based tag application works correctly.

#### Acceptance Criteria

1. IF the `apply_tags_on_views` macro in `macros/apply_tags_on_views.sql` is no longer needed under the new dbt-tags 1.9.0+ governance system, THEN THE Migration_Tool SHALL remove the file `macros/apply_tags_on_views.sql`
2. IF the `apply_tags_on_views` macro is still required, THEN THE Migration_Tool SHALL update the macro to use the new tag format with the equals separator and UPPER CASE values

### Requirement 9: Validate Tag Migration Completeness

**User Story:** As a data engineer, I want to verify that no legacy tags remain in the project after migration, so that the governance migration is complete and consistent.

#### Acceptance Criteria

1. WHEN the migration is complete, THE Migration_Tool SHALL contain zero occurrences of Legacy_Tag patterns (matching `pi_` prefix tags) in any Model_YML file
2. WHEN the migration is complete, THE Migration_Tool SHALL contain zero occurrences of UPPER CASE Legacy_Tag patterns (matching `PI_` prefix without equals separator) in the dbt_project_config `+tags` lists
3. WHEN the migration is complete, THE Migration_Tool SHALL contain zero `create_masking_policy__*` macro definitions in the project macros directory

### Requirement 10: Maintain Post-Hook Tag Application

**User Story:** As a data engineer, I want the existing `dbt_tags.apply_column_tags()` post-hook to remain functional, so that tags continue to be applied to models after materialisation.

#### Acceptance Criteria

1. THE dbt_project_config SHALL retain the existing `+post-hook` configuration that calls `dbt_tags.apply_column_tags()` within the `{% if flags.WHICH in ('run', 'build') %}` guard
2. WHEN a model is built with the new tag format, THE Post_Hook SHALL apply the New_Tag values to the corresponding Snowflake columns

### Requirement 11: Production Deployment Readiness

**User Story:** As a data engineer, I want the migration to be deployable to production before proceeding to subsequent governance steps, so that the migration is validated in a live environment.

#### Acceptance Criteria

1. THE Migration_Tool SHALL compile without errors using `dbt compile` after all changes are applied
2. THE Migration_Tool SHALL pass all existing data tests using `dbt test` after all changes are applied
3. WHEN deployed to the PRD environment, THE Migration_Tool SHALL apply the new governance tags to all models that previously had legacy PI tags
