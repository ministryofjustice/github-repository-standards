# Functions used by the app
module HelperModule
  include Constants

  # Collect the issues from a repository on GitHub
  #
  # @param repository_name [String] name of the repository
  # @return [Array<Hash{login => String, title => String, assignees => [Array<String>], number => Numeric}>] the issues in json format
  def get_issues_from_github(repository_name)
    url = "#{GH_API_URL}/#{repository_name.downcase}/issues"
    response = GithubRepositoryStandards::HttpClient.new.fetch_json(url)
    JSON.parse(response, {symbolize_names: true})
  end

  # Write public repository data to a file
  #
  # @param results [Array<Hash{name => String, default_branch => String, repo_url => String, status => String, last_push => Date, report => Hash, is_private => boolean }]}>] the list of repository data
  def write_public_data(results)
    public_repos = results.reject { |r| r.dig(:is_private) == true }

    if public_repos.length > 0
      public_repos_json = {
        data: public_repos
      }.to_json

      File.write("public_data.json", public_repos_json)
    end
  end

  # Write private repository data to a file
  #
  # @param results [Array<Hash{name => String, default_branch => String, repo_url => String, status => String, last_push => Date, report => Hash, is_private => boolean }]}>] the list of repository data
  def write_private_data(results)
    private_repos = results.reject { |r| r.dig(:is_private) == false }

    if private_repos.length > 0
      private_repos_json = {
        data: private_repos
      }.to_json

      File.write("private_data.json", private_repos_json)
    end
  end

  # Create issue ftn
  #
  # @param repository_name [String] name of the repository
  def create_default_branch_issue(repository_name)
    if does_issue_already_exist(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, repository_name) == false
      url = "#{GH_API_URL}/#{repository_name}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, default_branch_issue_hash.to_json)
      sleep 2
    end
  end

  # Create issue ftn
  #
  # @param repository_name [String] name of the repository
  def create_requires_approving_reviews_issue(repository_name)
    if does_issue_already_exist(ISSUE_TITLE_REQUIRE_APROVERS, repository_name) == false
      url = "#{GH_API_URL}/#{repository_name}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, requires_approving_reviews_issue_hash.to_json)
      sleep 2
    end
  end

  # Create issue ftn
  #
  # @param repository_name [String] name of the repository
  def create_include_administrators_issue(repository_name)
    if does_issue_already_exist(ISSUE_TITLE_INCLUDE_ADMINISTRATORS, repository_name) == false
      url = "#{GH_API_URL}/#{repository_name}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, include_administrators_issue_hash.to_json)
      sleep 2
    end
  end

  # Create issue ftn
  #
  # @param repository_name [String] name of the repository
  def create_require_approvals_issue(repository_name)
    if does_issue_already_exist(ISSUE_TITLE_INCORRECT_MINIMUM_APROVERS, repository_name) == false
      url = "#{GH_API_URL}/#{repository_name}/issues"
      GithubRepositoryStandards::HttpClient.new.post_json(url, require_approvals_issue_hash.to_json)
      sleep 2
    end
  end

  # Check if an open issue from the repo already exists
  #
  # @param issue_title [String] title of the Issue
  # @param repository_name [String] name of the repository
  # @return [Bool] True if issue exists already
  def does_issue_already_exist(issue_title, repository)
    issue_exists = false

    response_json = get_issues_from_github(repository)

    if response_json.nil? || response_json.empty?
      # Return empty array if no issues
    else
      # Get Issues used by this application based on the title
      issues = response_json.select { |x| x[:title].include? issue_title }
      if !issues.nil? || !issues&.empty?
        open_issues = []
        open_issues = issues.select { |x| x[:state] == "open" }
        if open_issues.length > 0
          issue_exists = true
        end
      end
    end
    issue_exists
  end

  # Composes a GitHub Issue structured message
  #
  # @return [Hash{title => String, assignees => Array<String>, body => String}] the Issue to send to GitHub
  def default_branch_issue_hash
    {
      title: ISSUE_TITLE_WRONG_DEFAULT_BRANCH,
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

  # Composes a GitHub Issue structured message
  #
  # @return [Hash{title => String, assignees => Array<String>, body => String}] the Issue to send to GitHub
  def requires_approving_reviews_issue_hash
    {
      title: ISSUE_TITLE_REQUIRE_APROVERS,
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

  # Composes a GitHub Issue structured message
  #
  # @return [Hash{title => String, assignees => Array<String>, body => String}] the Issue to send to GitHub
  def include_administrators_issue_hash
    {
      title: ISSUE_TITLE_INCLUDE_ADMINISTRATORS,
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

  # Composes a GitHub Issue structured message
  #
  # @return [Hash{title => String, assignees => Array<String>, body => String}] the Issue to send to GitHub
  def require_approvals_issue_hash
    {
      title: ISSUE_TITLE_INCORRECT_MINIMUM_APROVERS,
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
