# Functions used by the app
module HelperModule
  include Constants

  # Collect the issues from a repository on GitHub
  #
  # @param repository [String] name of the repository
  # @return [Array<Hash{login => String, title => String, assignees => [Array<String>], number => Numeric}>] the issues in json format
  def get_issues_from_github(repository)
    url = "#{GH_API_URL}/#{repository.downcase}/issues"
    response = GithubRepositoryStandards::HttpClient.new.fetch_json(url)
    JSON.parse(response, {symbolize_names: true})
  end

  def write_public_data(results)
    public_repos = results.reject { |r| r.dig(:is_private) == true }

    if public_repos.length > 0
      public_repos_json = {
        data: public_repos
      }.to_json

      File.write("public_data.json", public_repos_json)
    end
  end

  def write_private_data(results)
    private_repos = results.reject { |r| r.dig(:is_private) == false }

    if private_repos.length > 0
      private_repos_json = {
        data: private_repos
      }.to_json

      File.write("private_data.json", private_repos_json)
    end
  end

  def create_default_branch_issue(repository)
    if issue_already_exists("Default branch is not main", repository).empty?
      url = "#{GH_API_URL}/#{repository}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, default_branch_issue_hash.to_json)
      sleep 2
    end
  end

  def create_requires_approving_reviews_issue(repository)
    if issue_already_exists("A branch protection setting is not enabled: requires approving reviews", repository).empty?
      url = "#{GH_API_URL}/#{repository}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, requires_approving_reviews_issue_hash.to_json)
      sleep 2
    end
  end

  def create_include_administrators_issue(repository)
    if issue_already_exists("A branch protection setting is not enabled: Include administrators", repository).empty?
      url = "#{GH_API_URL}/#{repository}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, include_administrators_issue_hash.to_json)
      sleep 2
    end
  end

  def create_require_approvals_issue(repository)
    if issue_already_exists("A branch protection setting is not enabled: Require approvals", repository).empty?
      url = "#{GH_API_URL}/#{repository}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, require_approvals_issue_hash.to_json)
      sleep 2
    end
  end

  # Returns an open issue from the repo if it already exists
  def issue_already_exists(issue_title, repository)

    response_json = get_issues_from_github(repository)

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

  def default_branch_issue_hash
    {
      title: "Default branch is not main",
      assignees: [ORG],
      body: <<~EOF
        Hi there
        The default branch for this repository is not set to main
        See repository settings/Branches/Default branch to rename the default branch to main and ensure the Branch protection rules is set to main as well
        See the repository standards: https://github.com/ministryofjustice/github-repository-standards
        See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html
        Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
      EOF
    }
  end

  def requires_approving_reviews_issue_hash
    {
      title: "A branch protection setting is not enabled: requires approving reviews",
      assignees: [ORG],
      body: <<~EOF
        Hi there
        The default branch protection setting called requires approving reviews is not enabled for this repository
        See repository settings/Branches/Branch protection rules
        Either add a new Branch protection rule or edit the existing branch protection rule and select the Require approvals option
        This will require another persons approval on a pull request before it can be merged
        See the repository standards: https://github.com/ministryofjustice/github-repository-standards
        See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html
        Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
      EOF
    }
  end

  def include_administrators_issue_hash
    {
      title: "A branch protection setting is not enabled: Include administrators",
      assignees: [ORG],
      body: <<~EOF
        Hi there
        The default branch protection setting called Include administrators is not enabled for this repository
        See repository settings/Branches/Branch protection rules
        Either add a new Branch protection rule or edit the existing branch protection rule and select the Include administrators option
        This will enable the branch protection rules to admin uses as well
        See the repository standards: https://github.com/ministryofjustice/github-repository-standards
        See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html
        Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
      EOF
    }
  end

  def require_approvals_issue_hash
    {
      title: "A branch protection setting is not enabled: Require approvals",
      assignees: [ORG],
      body: <<~EOF
        Hi there
        The default branch protection setting called Require approvals is not enabled for this repository
        See repository settings/Branches/Branch protection rules
        Either add a new Branch protection rule or edit the existing branch protection rule and select the Require approvals option and select a minimum number of users to approve the pull request
        See the repository standards: https://github.com/ministryofjustice/github-repository-standards
        See the report: https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html
        Please contact Operations Engineering on Slack #ask-operations-engineering, if you need any assistance
      EOF
    }
  end

end