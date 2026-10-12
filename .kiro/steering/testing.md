# Testing Standards

## Approach
Data Quality First: Build → Test → Deploy

## Test Types
- **Generic Tests**: 15+ custom macros for data validation
  - SCD2 integrity checks (active row validation, overlap detection)
  - Source-to-target reconciliation
  - Primary key uniqueness validation
  - Record effectiveness validation
- **dbt Tests**: Built-in uniqueness, not_null, accepted_values
- **Integration Tests**: Daily full project test runs
- **CI Tests**: PR-triggered builds on isolated schemas

## Coverage Requirements
- **Critical Models**: 100% test coverage required
- **Data Services Layer**: All models must have PI compliance tests
- **SCD2 Models**: Mandatory historical integrity tests
- **Source Reconciliation**: All stage models require count checks

## Quality Gates
- **Severity**: Tests default to 'warn' to prevent pipeline breaks
- **Business Critical**: Error severity for compliance violations
- **Daily Monitoring**: Automated test execution and reporting

## Custom Test Implementations
- `check_one_active_row`: Validates SCD2 active record uniqueness
- `check_record_effectiveness_overlap`: Prevents temporal data conflicts
- `check_raw_stg_cnt`: Source-to-target record count validation
- `count_check_of_insert_updates`: DMS operation validation
- `check_latest_extraction_ts_active`: Ensures latest data is active