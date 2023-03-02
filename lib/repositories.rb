# The GithubRepositoryStandards class namespace
class GithubRepositoryStandards
  # The Repositories class
  class Repositories
    include Constants

    def initialize
      @graphql = GithubRepositoryStandards::GithubGraphQlClient.new
    end

    def list
      @list ||= get_all_repos
        .reject { |r| r.dig("repo", "isDisabled") }
        .reject { |r| r.dig("repo", "isLocked") }
    end

    private

    def get_all_repos
      get_repos("public") + get_repos("private") + get_repos("internal")
    end

    def get_repos(type = nil)
      repos = []
      end_cursor = nil
      loop do
        response = @graphql.run_query(repositories_query(end_cursor, type))
        json_data = JSON.parse(response).dig("data", "search")
        if !json_data.nil?
          json_data.fetch("repos").each do |repo|
            repos.push(repo)
          end
        end
        end_cursor = json_data.dig("pageInfo", "endCursor")
        break unless json_data.dig("pageInfo", "hasNextPage")
      end
      repos
    end

    def repositories_query(end_cursor, type)
      after = end_cursor.nil? ? "null" : "\"#{end_cursor}\""
      %[
        {
          search(
            type: REPOSITORY
            query: "org:#{ORG}, archived:false, is:#{type}"
            first: 100
            after: #{after}
          ) {
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
end