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
  #   * have non-empty description
  def report
    {
      name: repo_name,
      default_branch: default_branch,
      url: repo_url,
      status: status,
      last_push: last_push,
      report: all_checks_result,
      issues_enabled: issues_enabled
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

  def branch_protection_rules
    repo_data.dig("repo", "branchProtectionRules", "edges")
  end

  def all_checks_result
    result = false
    main_exists = false
    branch_protection_rule.each { |branch_protection_rule|
      if branch_protection_rule.dig("node", "pattern") == "main"
        main_exists = true
        result ||= {
          default_branch_main: default_branch_main?,
          has_default_branch_protection: has_default_branch_protection?(branch_protection_rule),
          requires_approving_reviews: has_branch_protection_property?(branch_protection_rule, "requiresApprovingReviews"),
          administrators_require_review: has_branch_protection_property?(branch_protection_rule, "isAdminEnforced"),
          issues_section_enabled: has_issues_enabled?,
          requires_code_owner_reviews: has_branch_protection_property?(branch_protection_rule, "requiresCodeOwnerReviews"),
          has_require_approvals_enabled: has_required_appproving_review_count?(branch_protection_rule)
        }
      end
    }
    if main_exists == false
      result ||= {
        default_branch_main: false,
        has_default_branch_protection: true,
        requires_approving_reviews: true,
        administrators_require_review: true,
        issues_section_enabled: true,
        requires_code_owner_reviews: true,
        has_require_approvals_enabled: true
      }
    end
    result
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
end
