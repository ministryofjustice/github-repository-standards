require_relative "http_client"

class GithubRepositoryStandards
  class IssueCreator
    attr_reader :owner, :repository, :github_user
    output_file = "output.txt"

    def initialize(params)
      @owner = params.fetch(:owner)
      @repository = params.fetch(:repository)
      @github_user = params.fetch(:github_user)
    end

    def create_default_branch_issue
      if issue_already_exists("Default branch is not main").empty?
        File.open(output_file, "a") { |file| file.write("Create default branch issue in repository: #{repository} \n") }
        url = "https://api.github.com/repos/#{owner}/#{repository}/issues"
        HttpClient.new.post_json(url, default_branch_issue_hash.to_json)
        sleep 5
      end
    end

    def create_requires_approving_reviews_issue
      if issue_already_exists("A branch protection setting is not enabled: requires approving reviews").empty?
        File.open(output_file, "a") { |file| file.write("Create requires approving reviews issue in repository: #{repository} \n") }
        url = "https://api.github.com/repos/#{owner}/#{repository}/issues"
        HttpClient.new.post_json(url, requires_approving_reviews_issue_hash.to_json)
        sleep 5
      end
    end

    def create_include_administrators_issue
      if issue_already_exists("A branch protection setting is not enabled: Include administrators").empty?
        File.open(output_file, "a") { |file| file.write("Create Include administrators issue in repository: #{repository} \n") }
        url = "https://api.github.com/repos/#{owner}/#{repository}/issues"
        HttpClient.new.post_json(url, include_administrators_issue_hash.to_json)
        sleep 5
      end
    end

    def create_require_approvals_issue
      if issue_already_exists("A branch protection setting is not enabled: Require approvals").empty?
        File.open(output_file, "a") { |file| file.write("Create Require approvals issue in repository: #{repository} \n") }
        url = "https://api.github.com/repos/#{owner}/#{repository}/issues"
        HttpClient.new.post_json(url, require_approvals_issue_hash.to_json)
        sleep 5
      end
    end

    # Returns an open issue from the repo if it already exists
    def issue_already_exists(issue_title)
      url = "https://api.github.com/repos/#{owner}/#{repository}/issues"

      # Fetch all issues for repo
      response = HttpClient.new.fetch_json(url).body
      response_json = JSON.parse(response, {symbolize_names: true})

      # Return empty array if no issues
      if response_json.nil? || response_json.empty?
        []
      else
        # Get only issues used by this application
        issues = response_json.select { |x| x[:title].include? issue_title }

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

    def default_branch_issue_hash
      {
        title: "Default branch is not main",
        assignees: [github_user],
        body: <<~EOF
          Hi there
          The default branch for this repository is not set to main
          See repository settings/Branches/Default branch to rename the default branch to main and ensure the Branch protection rules is set to main as well
          See the repository standards: https://github.com/ministryofjustice/github-repository-standards
          See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories
          Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
        EOF
      }
    end

    def requires_approving_reviews_issue_hash
      {
        title: "A branch protection setting is not enabled: requires approving reviews",
        assignees: [github_user],
        body: <<~EOF
          Hi there
          The default branch protection setting called requires approving reviews is not enabled for this repository
          See repository settings/Branches/Branch protection rules
          Either add a new Branch protection rule or edit the existing branch protection rule and select the Require approvals option
          This will require another persons approval on a pull request before it can be merged
          See the repository standards: https://github.com/ministryofjustice/github-repository-standards
          See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories
          Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
        EOF
      }
    end

    def include_administrators_issue_hash
      {
        title: "A branch protection setting is not enabled: Include administrators",
        assignees: [github_user],
        body: <<~EOF
          Hi there
          The default branch protection setting called Include administrators is not enabled for this repository
          See repository settings/Branches/Branch protection rules
          Either add a new Branch protection rule or edit the existing branch protection rule and select the Include administrators option
          This will enable the branch protection rules to admin uses as well
          See the repository standards: https://github.com/ministryofjustice/github-repository-standards
          See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories
          Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
        EOF
      }
    end

    def require_approvals_issue_hash
      {
        title: "A branch protection setting is not enabled: Require approvals",
        assignees: [github_user],
        body: <<~EOF
          Hi there
          The default branch protection setting called Require approvals is not enabled for this repository
          See repository settings/Branches/Branch protection rules
          Either add a new Branch protection rule or edit the existing branch protection rule and select the Require approvals option and select a minimum number of users to approve the pull request
          See the repository standards: https://github.com/ministryofjustice/github-repository-standards
          See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories
          Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
        EOF
      }
    end
  end
end
