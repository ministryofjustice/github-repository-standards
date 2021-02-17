class RepositoryReport < GithubGraphQlClient
  attr_reader :organization, :exceptions, :repo_name, :team

  MAIN_BRANCH = "main"
  ADMIN = "admin"
  PASS = "PASS"
  FAIL = "FAIL"

  def initialize(params)
    @organization = params.fetch(:organization)
    @exceptions = params.fetch(:exceptions) # repos which are allowed to break the rules
    @repo_name = params.fetch(:repo_name)
    @team = params.fetch(:team)
    super(params)
  end

  # TODO: additional checks
  #   * has issues enabled
  #   * deleteBranchOnMerge
  #   * mergeCommitAllowed (do we want this on or off?)
  #   * squashMergeAllowed (do we want this on or off?)

  def report
    {
      organization: organization,
      name: repo_name,
      default_branch: default_branch,
      url: repo_url,
      status: status,
      report: all_checks_result
    }
  end

  private

  def repo_data
    @repo_data ||= fetch_repo_data
  end

  def repo_url
    @url ||= repo_data.dig("data", "repository", "url")
  end

  def status
    if exceptions.include?(repo_name)
      PASS
    else
      all_checks_result.values.all? ? PASS : FAIL
    end
  end

  def all_checks_result
    @all_checks_result ||= {
      default_branch_main: default_branch_main?,
      has_main_branch_protection: has_main_branch_protection?,
      requires_approving_reviews: has_branch_protection_property?("requiresApprovingReviews"),
      requires_code_owner_reviews: has_branch_protection_property?("requiresCodeOwnerReviews"),
      administrators_require_review: has_branch_protection_property?("isAdminEnforced"),
      dismisses_stale_reviews: has_branch_protection_property?("dismissesStaleReviews"),
      team_is_admin: is_team_admin?,
    }
  end

  def fetch_repo_data
    body = repo_settings_query(
      organization: organization,
      repo_name: repo_name,
    )

    json = run_query(
      body: body,
      token: github_token
    )

    JSON.parse(json)
  end

  def repo_settings_query(params)
    owner = params.fetch(:organization)
    repo_name = params.fetch(:repo_name)

    %[
      {
        repository(owner: "#{owner}", name: "#{repo_name}") {
          name
          url
          owner {
            login
          }
          defaultBranchRef {
            name
          }
          branchProtectionRules(first: 50) {
            edges {
              node {
                pattern
                requiresApprovingReviews
                requiresCodeOwnerReviews
                isAdminEnforced
                dismissesStaleReviews
                requiresStrictStatusChecks
              }
            }
          }
        }
      }
    ]
  end

  def default_branch
    repo_data.dig("data", "repository", "defaultBranchRef", "name")
  end

  def is_team_admin?
    client = Octokit::Client.new(access_token: github_token)

    client.repo_teams([organization, repo_name].join("/")).select do |t|
      t[:name] == team && t[:permission] == ADMIN
    end.any?
  rescue Octokit::NotFound
    # This happens if our token does not have permission to view repo settings
    false
  end

  def branch_protection_rules
    @rules ||= repo_data.dig("data", "repository", "branchProtectionRules", "edges")
  end

  def default_branch_main?
    default_branch == MAIN_BRANCH
  end

  def has_main_branch_protection?
    requiring_branch_protection_rules do |rules|

      rules
        .select { |edge| edge.dig("node", "pattern") == MAIN_BRANCH }
        .any?
    end
  end

  def has_branch_protection_property?(property)
    requiring_branch_protection_rules do |rules|
      rules
        .map { |edge| edge.dig("node", property) }
        .all?
    end
  end

  def requiring_branch_protection_rules
    rules = branch_protection_rules
    return false unless rules.any?

    yield rules
  end

end
