class GithubRepositoryStandards
  include TestConstants
  include Constants

  describe StandardsReport do
    repo_data = {
      data:
        [
          {
            name: TEST_REPO_NAME.to_s,
            default_branch: "main",
            url: REPO_URL.to_s,
            status: "PASS",
            last_push: "2023-03-07",
            report:
              {
                default_branch_main: true,
                has_default_branch_protection: true,
                requires_approving_reviews: true,
                administrators_require_review: true,
                issues_section_enabled: true,
                has_require_approvals_enabled: true,
                has_license: true,
                has_description: true
              },
            is_private: true
          }
        ]
    }
    subject(:standards_report) { described_class.new(repo_data) }
  end
end
