require_relative "http_client"

class GithubRepositoryStandards
  class IssueCreator
    attr_reader :owner, :repository, :github_user

    def initialize(params)
      @owner = params.fetch(:owner)
      @repository = params.fetch(:repository)
      @github_user = params.fetch(:github_user)
    end

    def create_issue
      if issue_already_exists.empty?
        puts "Create issue in repository: #{repository}"
        url = "https://api.github.com/repos/#{owner}/#{repository}/issues"
        HttpClient.new.post_json(url, issue_hash.to_json)
        sleep 5
      end
    end

    # Returns an open issue from the repo if it already exists
    def issue_already_exists
      url = "https://api.github.com/repos/#{owner}/#{repository}/issues"

      # Fetch all issues for repo
      response = HttpClient.new.fetch_json(url).body
      response_json = JSON.parse(response, {symbolize_names: true})

      # Return empty array if no issues
      if response_json.nil? || response_json.empty?
        []
      else
        # Get only issues used by this application
        issues = response_json.select { |x| x[:title].include? "Default branch is not main" }

        # Check if there is an open issue
        if !issues.nil? && !issues&.empty?
          # Return the open issue
          issues.select { |x| x[:state] == "open" }
        else
          # No open issue
          []
        end
      end
    end

    private

    def issue_hash
      {
        title: "Default branch is not main",
        assignees: [github_user],
        body: <<~EOF
          Hi there
          The default branch for this repository is not set to main
          See repository settings/settings/branches to rename the default branch to main and ensure the Branch protection rules is set to main as well
          See the repository standards: https://github.com/ministryofjustice/github-repository-standards
          See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories
          Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
        EOF
      }
    end
  end
end
