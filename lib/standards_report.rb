# Given a hash of data representing a repository, analyse it to see whether it
# complies with our standards, and report any violations.
class StandardsReport
  attr_reader :repo_data

  MAIN_BRANCH = "main"
  ADMIN = "admin"
  PASS = "PASS"
  FAIL = "FAIL"

  def initialize(repo_data)
    @repo_data = repo_data
  end

  def report
    {
      name: repo_name,
      default_branch: default_branch,
      url: repo_url,
      status: status,
      last_push: last_push,
      report: all_checks_result,
      is_private: is_private
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

  def get_branch_protection_rules
    repo_data.dig("repo", "branchProtectionRules", "edges")
  end

  def all_checks_result
    {
      default_branch_main: default_branch_main?,
      has_default_branch_protection: has_default_branch_protection_enabled,
      requires_approving_reviews: has_branch_protection_property?(branch_protection_rule, "requiresApprovingReviews"),
      administrators_require_review: has_branch_protection_property?(branch_protection_rule, "isAdminEnforced"),
      issues_section_enabled: has_issues_enabled?,
      has_require_approvals_enabled: has_required_appproving_review_count?(branch_protection_rule),
      has_license: has_license?,
      has_description: has_description?
    }
  end

  def has_default_branch_protection_enabled
    default_branch_protection = false
    get_branch_protection_rules.each do |branch_protection_rule|
      if branch_protection_rule.dig("node", "pattern") == MAIN_BRANCH
        default_branch_protection = has_default_branch_protection?(branch_protection_rule)
      end
    end
    default_branch_protection
  end

  def issues_enabled
    repo_data.dig("repo", "hasIssuesEnabled")
  end

  def has_issues_enabled?
    issues_enabled == true
  end

  def default_branch
    repo_data.dig("repo", "defaultBranchRef", "name")
  end

  def branch_protection_rules
    @rules ||= repo_data.dig("repo", "branchProtectionRules", "edges")
  end

  def default_branch_main?
    default_branch == MAIN_BRANCH
  end

  def has_default_branch_protection?(branch_protection_rule)
    pattern = branch_protection_rule.dig("node", "pattern")
    pattern == default_branch
  end

  def has_required_appproving_review_count?(branch_protection_rule)
    approval_count = branch_protection_rule.dig("node", "requiredApprovingReviewCount")
    if approval_count.nil?
      false
    else
      approval_count > 0
    end
  end

  def has_branch_protection_property?(branch_protection_rule, property)
    branch_protection_rule.dig("node", property)
  end

  def get_license
    t = repo_data.dig("repo", "licenseInfo", "name")
    t.nil? ? "" : t.downcase
  end

  def has_license?
    get_license.include? "mit"
  end

  def get_description
    t = repo_data.dig("repo", "description")
    t.nil? ? 0 : t.length
  end

  def has_description?
    get_description > 0
  end

  def is_private
    repo_data.dig("repo", "isPrivate")
  end
end
