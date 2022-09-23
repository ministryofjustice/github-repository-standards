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
    get_public_repos() + get_private_repos() + get_internal_repos()
  end

  def get_public_repos
    graphql.get_paginated_results do |end_cursor|
      data = get_repos(end_cursor, "public")
      arr = data.fetch("repos")
      [arr, data]
    end
  end

  def get_private_repos
    graphql.get_paginated_results do |end_cursor|
      data = get_repos(end_cursor, "private")
      arr = data.fetch("repos")
      [arr, data]
    end
  end

  def get_internal_repos
    graphql.get_paginated_results do |end_cursor|
      data = get_repos(end_cursor, "internal")
      arr = data.fetch("repos")
      [arr, data]
    end
  end

  def get_repos(end_cursor = nil, type = nil)
    json = graphql.run_query(repositories_query(end_cursor, type))
    JSON.parse(json).dig("data", "search")
  end

  def repositories_query(end_cursor, type)
    after = end_cursor.nil? ? "" : %(, after: "#{end_cursor}")
    repo_type = type.nil? ? "" : %(, is:#{type})
    %[
{
  search(type: REPOSITORY, query: "org:ministryofjustice, archived:false#{repo_type}", first: #{PAGE_SIZE} #{after}) {
    repos: edges {
      repo: node {
        ... on Repository {
          name
          description
          url
          isPrivate
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
