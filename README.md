# Ministry of Justice GitHub Repository Standards

This repository contains code which uses the GitHub API to find all **public**
Ministry of Justice (MoJ) GitHub repositories, and check whether or not they
comply with our [standards].

These checks run on a regular schedule, and send the results to the [Operations
Engineering Reports] web application.

[standards]: https://ministryofjustice.github.io/technical-guidance/#building-software
[Operations Engineering Reports]: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/

## Public repositories should:

* be MIT Licensed
* have `main` as the default branch
* have at least one team with admin access (not implemented yet)
* delete branch on merge (not implemented yet)
* have non-empty description (shouldn't be null or "") (not implemented yet)
* have issues enabled (not implemented yet)
* have recent activity (pushedAt < ?) (not implemented yet)
* have branch protection on `main`, with:
    "requiresApprovingReviews": true,
    "requiresCodeOwnerReviews": true,
    "isAdminEnforced": true,
