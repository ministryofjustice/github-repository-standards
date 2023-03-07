class GithubRepositoryStandards
  include TestConstants
  include Constants

  describe StandardsReport do
    context "good path" do
      public_return_data = File.read("spec/fixtures/public-repo.json")
      json_data = JSON.parse(public_return_data)
      repo_data = json_data.dig("data", "search", "repos")

      subject(:standards_report) { described_class.new(repo_data[0]) }

      it "call is_private" do
        test_equal(standards_report.is_private, false)
      end

      it "call has_description" do
        test_equal(standards_report.has_description?, true)
      end

      it "call has_license" do
        test_equal(standards_report.has_license?, true)
      end

      it "call default_branch_main" do
        test_equal(standards_report.default_branch_main?, true)
      end

      it "call has_issues_enabled" do
        test_equal(standards_report.has_issues_enabled?, true)
      end

      it "call status" do
        test_equal(standards_report.status, PASS)
      end

      it "call repo_name" do
        test_equal(standards_report.repo_name, TEST_REPO_NAME)
      end

      it "call repo_url" do
        test_equal(standards_report.repo_url, "some-url")
      end

      it "call last_push" do
        reply = standards_report.last_push
        expect(reply).to be_instance_of(Date)
      end

      it "call has_default_branch_protection_enabled" do
        test_equal(standards_report.has_default_branch_protection_enabled, true)
      end

      it "call has_admin_requires_reviews_enabled" do
        test_equal(standards_report.has_admin_requires_reviews_enabled, true)
      end

      it "call has_requires_approving_reviews_enabled" do
        test_equal(standards_report.has_requires_approving_reviews_enabled, true)
      end

      it "call has_required_appproving_review_count_enabled" do
        test_equal(standards_report.has_required_appproving_review_count_enabled, true)
      end

      it "call report" do
        expectd_date = Date.strptime("{ 2023, 03, 07 }", "{ %Y, %m, %d }")
        bad_result = {name: TEST_REPO_NAME.to_s, default_branch: "main", url: "some-url", status: PASS, last_push: expectd_date, report: {default_branch_main: true, has_default_branch_protection: true, requires_approving_reviews: true, administrators_require_review: true, issues_section_enabled: true, has_require_approvals_enabled: true, has_license: true, has_description: true}, is_private: false}
        test_equal(standards_report.report, bad_result)
      end
    end

    context "bad path" do
      public_return_data = File.read("spec/fixtures/bad-repo.json")
      json_data = JSON.parse(public_return_data)
      repo_data = json_data.dig("data", "search", "repos")

      subject(:standards_report) { described_class.new(repo_data[0]) }

      it "call is_private" do
        test_equal(standards_report.is_private, true)
      end

      it "call has_description" do
        test_equal(standards_report.has_description?, false)
      end

      it "call has_license" do
        test_equal(standards_report.has_license?, false)
      end

      it "call default_branch_main" do
        test_equal(standards_report.default_branch_main?, false)
      end

      it "call has_issues_enabled" do
        test_equal(standards_report.has_issues_enabled?, false)
      end

      it "call status" do
        test_equal(standards_report.status, FAIL)
      end

      it "call has_default_branch_protection_enabled" do
        test_equal(standards_report.has_default_branch_protection_enabled, false)
      end

      it "call has_admin_requires_reviews_enabled" do
        test_equal(standards_report.has_admin_requires_reviews_enabled, false)
      end

      it "call has_requires_approving_reviews_enabled" do
        test_equal(standards_report.has_requires_approving_reviews_enabled, false)
      end

      it "call has_required_appproving_review_count_enabled" do
        test_equal(standards_report.has_required_appproving_review_count_enabled, false)
      end

      it "call report" do
        expectd_date = Date.strptime("{ 2023, 03, 07 }", "{ %Y, %m, %d }")
        bad_result = {name: TEST_REPO_NAME.to_s, default_branch: "master", url: "some-url", status: FAIL, last_push: expectd_date, report: {default_branch_main: false, has_default_branch_protection: false, requires_approving_reviews: false, administrators_require_review: false, issues_section_enabled: false, has_require_approvals_enabled: false, has_license: false, has_description: false}, is_private: true}
        test_equal(standards_report.report, bad_result)
      end
    end
  end
end
