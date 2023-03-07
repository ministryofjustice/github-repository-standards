class GithubRepositoryStandards
  include TestConstants
  include Constants

  describe HelperModule do
    let(:helper_module) { Class.new { extend HelperModule } }
    let(:http_client) { double(GithubRepositoryStandards::HttpClient) }
    let(:graphql_client) { double(GithubRepositoryStandards::GithubGraphQlClient) }

    context "" do
      private_input_data = [{"name":"#{TEST_REPO_NAME}","default_branch":"main","url":"#{REPO_URL}","status":"PASS","last_push":"2023-03-07","report":{"default_branch_main":true,"has_default_branch_protection":true,"requires_approving_reviews":true,"administrators_require_review":true,"issues_section_enabled":true,"has_require_approvals_enabled":true,"has_license":true,"has_description":true},"is_private":true}]
      public_input_data = [{"name":"#{TEST_REPO_NAME}","default_branch":"main","url":"#{REPO_URL}","status":"PASS","last_push":"2023-03-07","report":{"default_branch_main":true,"has_default_branch_protection":true,"requires_approving_reviews":true,"administrators_require_review":true,"issues_section_enabled":true,"has_require_approvals_enabled":true,"has_license":true,"has_description":true},"is_private":false}]
      private_expected_data = {"data": [{"name":"#{TEST_REPO_NAME}","default_branch":"main","url":"#{REPO_URL}","status":"PASS","last_push":"2023-03-07","report":{"default_branch_main":true,"has_default_branch_protection":true,"requires_approving_reviews":true,"administrators_require_review":true,"issues_section_enabled":true,"has_require_approvals_enabled":true,"has_license":true,"has_description":true},"is_private":true}]}
      public_expected_data = {"data": [{"name":"#{TEST_REPO_NAME}","default_branch":"main","url":"#{REPO_URL}","status":"PASS","last_push":"2023-03-07","report":{"default_branch_main":true,"has_default_branch_protection":true,"requires_approving_reviews":true,"administrators_require_review":true,"issues_section_enabled":true,"has_require_approvals_enabled":true,"has_license":true,"has_description":true},"is_private":false}]}
      url = "#{GH_API_URL}/#{TEST_REPO_NAME}/issues"
      
      default_branch_issue_hash = {
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

      requires_approving_reviews_issue_hash = {
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

      include_administrators_issue_hash = {
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

      require_approvals_issue_hash = {
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

      context "call write_public_data" do
        it "when have no data to send" do
          expect(File).not_to receive(:write)
          helper_module.write_public_data([])
        end
        
        it "when data is private" do
          expect(File).not_to receive(:write)
          helper_module.write_public_data(private_input_data)
        end

        it "when have data to send" do
          expect(File).to receive(:write).with("public_data.json", public_expected_data.to_json)
          helper_module.write_public_data(public_input_data)
        end
      end

      context "call write_private_data" do
        it "when have no data to send" do
          expect(File).not_to receive(:write)
          helper_module.write_private_data([])
        end
        
        it "when data is public" do
          expect(File).not_to receive(:write)
          helper_module.write_private_data(public_input_data)
        end

        it "when have data to send" do
          expect(File).to receive(:write).with("private_data.json", private_expected_data.to_json)
          helper_module.write_private_data(private_input_data)
        end
      end

      context "call get_issues_from_github" do
        before do
          expect(GithubRepositoryStandards::HttpClient).to receive(:new).and_return(http_client)
        end
        
        let(:json) { File.read("spec/fixtures/issues.json") }

        it "when no issues exist" do
          response = []
          expect(http_client).to receive(:fetch_json).with(TEST_URL).and_return(response.to_json)
          test_equal(helper_module.get_issues_from_github(TEST_REPO_NAME), [])
        end

        it "when issues exist" do
          expect(http_client).to receive(:fetch_json).with(TEST_URL).and_return(json)
          expect(helper_module.get_issues_from_github(TEST_REPO_NAME)).equal?(json)
        end
      end

      context "call does_issue_already_exist" do
        it "when no issues exists" do
          expect(helper_module).to receive(:get_issues_from_github).with(TEST_REPO_NAME).and_return([])
          test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME), false)
        end

        it "when return empty json" do
          expect(helper_module).to receive(:get_issues_from_github).with(TEST_REPO_NAME).and_return("")
          test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME), false)
        end

        it "when return nil value" do
          expect(helper_module).to receive(:get_issues_from_github).with(TEST_REPO_NAME).and_return(nil)
          test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME), false)
        end

        context "when issue exists" do
          before do
            issues_json = File.read("spec/fixtures/closed_issue.json")
            issues = JSON.parse(issues_json, {symbolize_names: true})
            expect(helper_module).to receive(:get_issues_from_github).with(TEST_REPO_NAME).and_return(issues)
          end

          it "but it is closed" do
            test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME), false)
          end

          it "but isn't the issue looking for" do
            test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_INCLUDE_ADMINISTRATORS, TEST_REPO_NAME), false)
          end
        end

        context "when issue exists" do
          before do
            issues_json = File.read("spec/fixtures/issues.json")
            issues = JSON.parse(issues_json, {symbolize_names: true})
            expect(helper_module).to receive(:get_issues_from_github).with(TEST_REPO_NAME).and_return(issues)
          end

          it "and it is a wrong default branch issue" do
            test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME), true)
          end

          it "and it is a requires a PR issue" do
            test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_REQUIRE_APROVERS, TEST_REPO_NAME), true)
          end

          it "and it is a admins need reviewing issue" do
            test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_INCLUDE_ADMINISTRATORS, TEST_REPO_NAME), true)
          end

          it "and it is a minimum approvers needed issue" do
            test_equal(helper_module.does_issue_already_exist(ISSUE_TITLE_INCORRECT_MINIMUM_APROVERS, TEST_REPO_NAME), true)
          end
        end
      end
    
      context "call hash functions" do
        it "call default_branch_issue_hash" do
          test_equal(helper_module.default_branch_issue_hash, default_branch_issue_hash)
        end
        
        it "call requires_approving_reviews_issue_hash" do
          test_equal(helper_module.requires_approving_reviews_issue_hash, requires_approving_reviews_issue_hash)
        end
      
        it "call include_administrators_issue_hash" do
          test_equal(helper_module.include_administrators_issue_hash, include_administrators_issue_hash)
        end
        
        it "call require_approvals_issue_hash" do
          test_equal(helper_module.require_approvals_issue_hash, require_approvals_issue_hash)
        end
      end
    
      context "call create_require_approvals_issue" do
        it "when issue already exists on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_INCORRECT_MINIMUM_APROVERS, TEST_REPO_NAME).and_return(true)
          expect(http_client).not_to receive(:post_json)
          helper_module.create_require_approvals_issue(TEST_REPO_NAME)
        end

        it "and create a new issue on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_INCORRECT_MINIMUM_APROVERS, TEST_REPO_NAME).and_return(false)
          expect(GithubRepositoryStandards::HttpClient).to receive(:new).and_return(http_client)
          expect(http_client).to receive(:post_json).with(url, require_approvals_issue_hash.to_json)
          helper_module.create_require_approvals_issue(TEST_REPO_NAME)
        end
      end
    
      context "call create_default_branch_issue" do
        it "when issue already exists on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME).and_return(true)
          expect(http_client).not_to receive(:post_json)
          helper_module.create_default_branch_issue(TEST_REPO_NAME)
        end

        it "and create a new issue on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_WRONG_DEFAULT_BRANCH, TEST_REPO_NAME).and_return(false)
          expect(GithubRepositoryStandards::HttpClient).to receive(:new).and_return(http_client)
          expect(http_client).to receive(:post_json).with(url, default_branch_issue_hash.to_json)
          helper_module.create_default_branch_issue(TEST_REPO_NAME)
        end
      end
    
      context "call create_requires_approving_reviews_issue" do
        it "when issue already exists on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_REQUIRE_APROVERS, TEST_REPO_NAME).and_return(true)
          expect(http_client).not_to receive(:post_json)
          helper_module.create_requires_approving_reviews_issue(TEST_REPO_NAME)
        end

        it "and create a new issue on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_REQUIRE_APROVERS, TEST_REPO_NAME).and_return(false)
          expect(GithubRepositoryStandards::HttpClient).to receive(:new).and_return(http_client)
          expect(http_client).to receive(:post_json).with(url, requires_approving_reviews_issue_hash.to_json)
          helper_module.create_requires_approving_reviews_issue(TEST_REPO_NAME)
        end
      end
      
      context "call create_include_administrators_issue" do
        it "when issue already exists on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_INCLUDE_ADMINISTRATORS, TEST_REPO_NAME).and_return(true)
          expect(http_client).not_to receive(:post_json)
          helper_module.create_include_administrators_issue(TEST_REPO_NAME)
        end

        it "and create a new issue on repo" do
          expect(helper_module).to receive(:does_issue_already_exist).with(ISSUE_TITLE_INCLUDE_ADMINISTRATORS, TEST_REPO_NAME).and_return(false)
          expect(GithubRepositoryStandards::HttpClient).to receive(:new).and_return(http_client)
          expect(http_client).to receive(:post_json).with(url, include_administrators_issue_hash.to_json)
          helper_module.create_include_administrators_issue(TEST_REPO_NAME)
        end
      end  
    end
  end
end