class GithubGraphQlClient
  attr_reader :github_token

  GITHUB_GRAPHQL_URL = "https://api.github.com/graphql"

  def initialize(params)
    @github_token = params.fetch(:github_token)
  end

  private

  def run_query(params)
    body = params.fetch(:body)
    token = params.fetch(:token)

    json = {query: body}.to_json
    headers = {"Authorization" => "bearer #{token}"}

    uri = URI.parse(GITHUB_GRAPHQL_URL)
    resp = Net::HTTP.post(uri, json, headers)

    resp.body
  end
end
