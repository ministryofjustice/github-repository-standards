# Ministry of Justice GitHub Repository Standards

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.data%5B%3F%28%40.name%20%3D%3D%20%22github-repository-standards%22%29%5D.status&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fgithub_repositories)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories#github-repository-standards "Link to report")

This repository contains code which uses the GitHub API to find all **public**
Ministry of Justice (MoJ) GitHub repositories, and check whether or not they
comply with our [standards].

These checks run on a regular schedule, and send the results to the [Operations
Engineering Reports] web application.

[standards]: https://ministryofjustice.github.io/technical-guidance/#building-software
[operations engineering reports]: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/

## Running the report

The report is scheduled to run daily, via a GitHub Actions workflow.

You can also trigger it manually via the "Run workflow" button [here](https://github.com/ministryofjustice/github-repository-standards/actions/workflows/post-report-data.yml).

The ruby code is run directly via the GitHub Actions workflow - there is no
docker image or other build steps.

## Architecture

- A GraphQL query retrieves information about MoJ public GitHub repositories
- Data for each repository is used to instantiate a `StandardsReport` object
- Code in `StandardsReport` creates a report based on the data supplied

## Public repositories should:

- be MIT Licensed (not implemented yet)
- have `main` as the default branch
- have non-empty description (shouldn't be null or "") (not implemented yet)
- have issues enabled
- have branch protection on `main`, with:
  1. Require a pull request before merging
  2. Require approvals option and a minimum number of user to approve the pull request.
  3. Include administrators option
