# Given a hash of data representing a repository, analyse it to see whether it
# complies with our standards, and report any violations.
#
# This should really be done via conftest, but I don't think I've got time to
# implement it that way.
#
# Also, an important check is whether any team, rather than an individual, has
# admin permissions on the repository. This information is not currently
# available via the GitHub GraphQL API.
class StandardsReport
  attr_reader :repo_data

  MAIN_BRANCH = "main"
  ADMIN = "admin"
  PASS = "PASS"
  FAIL = "FAIL"

  def initialize(repo_data)
    @repo_data = repo_data
  end

  # TODO: additional checks
  #   * MIT License
  #   * has issues enabled
  #   * deleteBranchOnMerge
  #   * There is a team with admin privileges on the repo
  def report
    {
      name: repo_name,
      default_branch: default_branch,
      url: repo_url,
      status: status,
      last_push: last_push,
      report: all_checks_result
    }
  end

  def ben 
    {
      name: repo_name,
      default_branch: default_branch,
      db: has_main_branch_protection?
    }
  end

  private

  def repo_name
    repo_data.dig("repo", "name")
  end

  def repo_url
    @url ||= repo_data.dig("repo", "url")
  end

  def status
    all_checks_result.values.all? ? PASS : FAIL
  end

  def last_push
    t = repo_data.dig("repo", "pushedAt")
    t.nil? ? nil : Date.parse(t)
  end

  def all_checks_result
    @all_checks_result ||= {
      default_branch_main: default_branch_main?,
      has_default_branch_protection: has_main_branch_protection?,
      requires_approving_reviews: has_branch_protection_property?("requiresApprovingReviews"),
      administrators_require_review: has_branch_protection_property?("isAdminEnforced"),
      # team_is_admin: is_team_admin?, # TODO: implement this, but pass if *any* team has admin rights.
    }
  end

  def default_branch
    repo_data.dig("repo", "defaultBranchRef", "name")
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
    @rules ||= repo_data.dig("repo", "branchProtectionRules", "edges")
  end

  def default_branch_main?
    default_branch == MAIN_BRANCH
  end

  def has_default_branch_protection?
    requiring_branch_protection_rules do |rules|
      rules
        .select { |edge| edge.dig("node", "pattern") == default_branch}
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
