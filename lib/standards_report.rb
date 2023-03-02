# The GithubRepositoryStandards class namespace
class GithubRepositoryStandards
  # The StandardsReport class
  class StandardsReport
    attr_reader :repo_data
    include Constants

    def initialize(repo_data)
      # One repository data as Hash/JSON 
      @repo_data = repo_data
    end

    # Creates a report of the data to write to file as a Hash data type
    #
    # @return [Array<Hash{name => String, default_branch => String, repo_url => String, status => String, last_push => Date, report => Hash, is_private => boolean }]}>]
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

    # Return the repository name
    #
    # @return [String] the repository name
    def repo_name
      repo_data.dig("repo", "name")
    end

    # Return the repository URL
    #
    # @return [String] the repository URL
    def repo_url
      @url ||= repo_data.dig("repo", "url")
    end

    # See if the repository passed/failed the Standards checks
    #
    # @return [String] the result
    def status
      all_checks_result.values.all? ? PASS : FAIL
    end

    # Return the last update on the repository
    #
    # @return [Date] the last update on the repository
    def last_push
      t = repo_data.dig("repo", "pushedAt")
      t.nil? ? nil : Date.parse(t)
    end

    # Return the branch protections rules for the repository
    #
    # @return [Array<Hash{}>] the branch protections rules   
    def get_branch_protection_rules
      repo_data.dig("repo", "branchProtectionRules", "edges")
    end

    # Check each Standard and return results as a Hash data type
    #
    # @return [Array<Hash{default_branch_main => Bool, has_default_branch_protection => Bool, requires_approving_reviews => Bool, administrators_require_review => Bool, issues_section_enabled => Bool, has_require_approvals_enabled => Bool, has_license => Bool, has_description => Bool}>] the Standards check results
    def all_checks_result
      {
        default_branch_main: default_branch_main?,
        has_default_branch_protection: has_default_branch_protection_enabled,
        requires_approving_reviews: has_requires_approving_reviews_enabled,
        administrators_require_review: has_admin_requires_reviews_enabled,
        issues_section_enabled: has_issues_enabled?,
        has_require_approvals_enabled: has_required_appproving_review_count_enabled,
        has_license: has_license?,
        has_description: has_description?
      }
    end

    # Check Standard: branch protection enabled
    #
    # @return [Bool] true if branch protection is enabled on main branch
    def has_default_branch_protection_enabled
      default_branch_protection = false
      get_branch_protection_rules.each do |branch_protection_rule|
        if branch_protection_rule.dig("node", "pattern") == MAIN_BRANCH
          default_branch_protection = has_default_branch_protection?(branch_protection_rule)
        end
      end
      default_branch_protection
    end

    # Check Standard: PR require approvals enabled
    #
    # @return [Bool] true if PR require approvals is enabled on main branch
    def has_requires_approving_reviews_enabled
      requires_approving_reviews = false
      get_branch_protection_rules.each do |branch_protection_rule|
        if branch_protection_rule.dig("node", "pattern") == MAIN_BRANCH
          requires_approving_reviews = has_branch_protection_property?(branch_protection_rule, "requiresApprovingReviews")
        end
      end
      requires_approving_reviews
    end

    # Check Standard: Admin changes require reviews enabled
    #
    # @return [Bool] true if Admin changes require reviews is enabled on main branch
    def has_admin_requires_reviews_enabled
      admin_requires_reviews = false
      get_branch_protection_rules.each do |branch_protection_rule|
        if branch_protection_rule.dig("node", "pattern") == MAIN_BRANCH
          admin_requires_reviews = has_branch_protection_property?(branch_protection_rule, "isAdminEnforced")
        end
      end
      admin_requires_reviews
    end

    # Check Standard: PR require at least one approval enabled
    #
    # @return [Bool] true if PR require at least one approval is enabled on main branch
    def has_required_appproving_review_count_enabled
      required_appproving_review_count = false
      get_branch_protection_rules.each do |branch_protection_rule|
        if branch_protection_rule.dig("node", "pattern") == MAIN_BRANCH
          required_appproving_review_count = has_required_appproving_review_count?(branch_protection_rule)
        end
      end
      required_appproving_review_count
    end

    # Return the Issue section is enabled on a repository
    #
    # @return [Bool] true if the Issue section is enabled on a repository
    def issues_enabled
      repo_data.dig("repo", "hasIssuesEnabled")
    end
    
    # Check Standard: Issue section on repository enabled
    #
    # @return [Bool] true if Issue section on repository is enabled on repository
    def has_issues_enabled?
      issues_enabled == true
    end

    # Return the repository default branch name
    #
    # @return [String] repository default branch name
    def default_branch
      repo_data.dig("repo", "defaultBranchRef", "name")
    end

    # Return the repository branch protections rules per protected branch
    #
    # @return [Array<Hash{}>] the branch protections rules
    def branch_protection_rules
      @rules ||= repo_data.dig("repo", "branchProtectionRules", "edges")
    end

    # Check Standard: Main branch is default
    #
    # @return [Bool] true if the main branch is default
    def default_branch_main?
      default_branch == MAIN_BRANCH
    end

    # Check Standard: Branch protection applied to the main branch ie Main
    #
    # @param branch_protection_rule[Hash{}] The rules in a branch protection setting
    # @return [Bool] true if the main branch is default and has branch protection enabled
    def has_default_branch_protection?(branch_protection_rule)
      pattern = branch_protection_rule.dig("node", "pattern")
      pattern == default_branch
    end

    # Check Standard: At least one approver is needed on a PR
    #
    # @param branch_protection_rule[Hash{}] The rules in a branch protection setting
    # @return [Bool] true if the branch protection minimum approver is enabled
    def has_required_appproving_review_count?(branch_protection_rule)
      approval_count = branch_protection_rule.dig("node", "requiredApprovingReviewCount")
      if approval_count.nil?
        false
      else
        approval_count > 0
      end
    end

    # Check if rule is enabled inside a branch protection settings
    # 
    # @param branch_protection_rule[Hash{}] The rules in a branch protection setting
    # @param property[String] The rule to check for
    # @return [Bool] true if rule is enabled in the branch protection setting
    def has_branch_protection_property?(branch_protection_rule, property)
      branch_protection_rule.dig("node", property)
    end

    # Read the license type from the data
    # 
    # @return [String] the name of the license
    def get_license
      t = repo_data.dig("repo", "licenseInfo", "name")
      t.nil? ? "" : t.downcase
    end

    # Check Standard: MIT license is used within repository
    #
    # @return [Bool] true if MIT license is used
    def has_license?
      get_license.include? "mit"
    end

    # Return the repository description length
    #
    # @return [Numberic] The character length of the description
    def get_description
      t = repo_data.dig("repo", "description")
      t.nil? ? 0 : t.length
    end

    # Check Standard: The repository description is completed 
    #
    # @return [Bool] true if repository description is not empty
    def has_description?
      get_description > 0
    end

    # Return if the repository is private or not
    #
    # @return [Bool] true if repository is private   
    def is_private
      repo_data.dig("repo", "isPrivate")
    end
  end
end