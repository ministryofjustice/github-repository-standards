# Ministry of Justice GitHub Repository Standards

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fgithub-repository-standards)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#github-repository-standards "Link to report")

This repository contains code which uses the GitHub API to find all non archived
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

- A GraphQL query retrieves information about MoJ GitHub repositories
- Data for each repository is used to instantiate a `StandardsReport` object
- Code in `StandardsReport` creates a report based on the data supplied
- The data is saved to file
- The file is encrypted and sent to the Operations Engineering Reports web application.

## Repositories should:

- be MIT Licensed
- have `main` as the default branch
- have non-empty description (shouldn't be null or "")
- have issues enabled
- have branch protection on `main`, with:
  1. Require a pull request before merging
  2. Require approvals option and a minimum number of user to approve the pull request.
  3. Include administrators option
