class Repositories
  attr_reader :graphql

  PAGE_SIZE = 100

  def initialize(params)
    @graphql = params.fetch(:graphql)
  end

  def list
    @list ||= get_all_repos
      .reject { |r| r.dig("repo", "isDisabled") }
      .reject { |r| r.dig("repo", "isLocked") }
  end

  private

  def get_all_repos
    graphql.get_paginated_results do |end_cursor|
      data = get_repos(end_cursor)
      arr = data.fetch("repos")
      [arr, data]
    end
  end

  def get_repos(end_cursor = nil)
    json = graphql.run_query(repositories_query(end_cursor))
    JSON.parse(json).dig("data", "search")
  end

  def repositories_query(end_cursor)
    after = end_cursor.nil? ? "" : %(, after: "#{end_cursor}")
    %[
{
  search(type: REPOSITORY, query: "org:ministryofjustice, is:public, archived:false", first: #{PAGE_SIZE} #{after}) {
    repos: edges {
      repo: node {
        ... on Repository {
          name
          description
          url
          isDisabled
          isLocked
          hasIssuesEnabled
          pushedAt
          defaultBranchRef {
            name
          }
          licenseInfo {
            name
          }

          branchProtectionRules(first: 10) {
            edges {
              node {
                isAdminEnforced                  # Include administrators
                pattern                          # should be set to main
                requiredApprovingReviewCount     # Require approvals > 0
                requiresApprovingReviews         # Require a pull request before merging
              }
            }
          }
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
    ]
  end
end
