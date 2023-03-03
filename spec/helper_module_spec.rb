class GithubRepositoryStandards
  include TestConstants
  include Constants

  describe HelperModule do
    let(:helper_module) { Class.new { extend HelperModule } }

    let(:http_client) { double(GithubRepositoryStandards::HttpClient) }
    let(:graphql_client) { double(GithubRepositoryStandards::GithubGraphQlClient) }

    context "" do
      before do
      end

      context "call get_issues_from_github" do
        before do
          expect(GithubRepositoryStandards::HttpClient).to receive(:new).and_return(http_client)
        end

        # it "and return an issue" do
        #   response = %([{"assignee": { "login":#{TEST_USER}}, "title": #{ISSUE_TITLE_WRONG_DEFAULT_BRANCH}, "assignees": [{"login":#{TEST_USER} }]}])
        #   expect(http_client).to receive(:fetch_json).with(TEST_URL).and_return(response.to_json)
        #   test_equal(helper_module.get_issues_from_github(TEST_REPO_NAME), response)
        # end

        it "and return empty array if no issues" do
          response = []
          expect(http_client).to receive(:fetch_json).with(TEST_URL).and_return(response.to_json)
          test_equal(helper_module.get_issues_from_github(TEST_REPO_NAME), [])
        end

        let(:json) { File.read("spec/fixtures/issues.json") }
        it "return issues" do
          expect(http_client).to receive(:fetch_json).with(TEST_URL).and_return(json)
          expect(helper_module.get_issues_from_github(TEST_REPO_NAME)).equal?(json)
        end
      end

      # context "call does_issue_already_exist" do
      #   issues_json = File.read("spec/fixtures/issues.json")
      #   before do
      #     expect(helper_module).to receive(:remove_issue).with(TEST_REPO_NAME, 159)
      #   end

      #   it "when no issues exists" do
      #     issues = JSON.parse(issues_json, {symbolize_names: true})
      #     test_equal(helper_module.does_issue_already_exist(title, TEST_REPO_NAME), false)
      #     test_equal(issues.length, 3)
      #   end

      #   it "when issue exists" do
      #     issues = JSON.parse(issues_json, {symbolize_names: true})
      #     test_equal(helper_module.does_issue_already_exist(title, TEST_REPO_NAME), true)
      #     test_equal(issues.length, 3)
      #   end
      # end
    end
  end
end