# String constants used in app and tests
module Constants
  # GitHub reply when rate limiting is active
  RATE_LIMITED = "RATE_LIMITED"

  # Organization name
  ORG = "ministryofjustice"

  # The GitHub API URL for repositories
  GH_API_URL = "https://api.github.com/repos/#{ORG}"

  # The GitHub API URL for organisation
  GH_ORG_API_URL = "https://api.github.com/orgs/#{ORG}"

  # The GitHub Organization URL
  GH_ORG_URL = "https://github.com/#{ORG}"

  # The GitHub GraphQL API URL
  GRAPHQL_URI = "https://api.github.com/graphql"

  # The main branch
  MAIN_BRANCH = "main"

  # Pass string
  PASS = "PASS"

  # Fail string
  FAIL = "FAIL"
end
