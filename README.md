# pexa-one-data-au-exchange-dbt


This repo is used to model data from PEXA Exchange source systems; applying business logic, protects sensitive information and creates documented models ready for analysis.

This repo is the source for two different DBT Exchange projects:

- onedata-au-pexa-exchange (non-production)
- onedata-au-pexa-exchange-prod (production)

## Project Overview

This project implements the [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture), which is a data lake architecture pattern that champions the ELT methodology, prioritizing agility and speed in data ingestion while deferring complex transformations to later stages.

- **dbt_project.yml**: Central configuration for the project, instructs dbt how to interact with models, sources and more.

-  **models/curate**: Parsing, flattening, cleaning, transforming raw data into curated datasets

-  **models/data_services**: Analytics-ready data marts built from curated models

- **tests/generic**: Macros for data quality tests

- **macros**: Commonly used macros such as tagging and masking policies

- **helpers**: Python scripts to help automate manual tasks


## Getting Started

### Requirements

You may need to request access via PEXA access catalogue if don't already have access.

- DBT Cloud (developer)
- Snowflake Exchange AU (engineer)

### Setup on DBT Cloud

Reach out to ONEData team if assistance is required

**Project Credentials**: One time setup (already done)

**User Credentials**: One time setup (already done)
- For `Schema` - input your own name;  this will be the projects default if no schema is specificied in source code


## Environments

#### Non-Production

- **DEV**: runs against your `feature/**` branch
- **STG**: staging environment before promoting to TST
- **TEST**: runs against `develop` branch

#### Production

- **PST**: runs against a `release/**` branch
- **PRD**: runs against `main` branch

## Usage

### Local Development

We mostly do our development on DBT Cloud IDE, to deploy changes into DEV dbt commands are executed in Cloude IDE command. You can also validate your changes in Snowflake.

_future exploration:_ [dbt cloud cli](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)

### DBT CI Jobs

DBT Jobs are abstracted by `environments` and `source`. This is so jobs can run in isolation without impacting downstreams of other sources.

In this project dbt jobs are separated by:


**Scheduled**

These are cron jobs that are set to run on a particular schedule:
- `Log <ENV> Splunk`: Pushes logs into S3 bucket for security team to ingest. Logs contains traceability of access history, grants, query history etc.

- `Integration tests <ENV>`: Runs `dbt test` on entire project daily

**Deploy Jobs**

Order of job execution is important; run these jobs if applicable to your development

1. `Create and Apply <ENV> tags and masking policies`
- Only required to run when need to create new tags or new masking policies

2. `Build <ENV> <SOURCE> views`
- Isolated build targeting a particular source or set of models at a time.
ie: Exchange or Projects - as this will drop the datashare for views and datashare grants will need to be re-applied

3. `Tag <ENV> tables with PI`
- This needs to be run after build, if a table/view contains PI it will tag it with (yes / no ) values

**Continuous integration job**

- `STG CI Build`
    - Triggers on PR's and commit pushes, runs `dbt build` on entire project
    - This runs on a separate schemas `dbt_cloud_pr_xx` so it doesn't interfer with the data with dev or tst

## Contributing
**Issues:** Report bugs or request new features by creating a new issue or raising a JIRA ticket

**Pull Requests:** Follow the existing coding style and standards. Refer to the [contribution guidelines](CONTRIBUTING.md) for more details.

**Communication:** Join the #pexa-data-engineering-and-delivery channel on Slack