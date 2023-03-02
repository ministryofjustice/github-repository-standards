# The GithubRepositoryStandards class namespace
class GithubRepositoryStandards  
  # The GithubGraphQlClient class
  class GithubGraphQlClient
    include Constants

    # Get data from Github using the GraphQL API

    def initialize
      # Keep here so abort when object is created if the token is missing
      @github_token = ENV.fetch("ADMIN_GITHUB_TOKEN")
    end

    # Checks the header and body content replied from a GitHub query is correct
    #
    # @param response [Net::HTTPResponse] the response object
    # @return [Bool] true if no issue were found in the reply
    def is_response_okay(response)

      if response.nil? || response == "" || response.code != "200"
        return false
      end

      if response.body.nil? || response.body == ""
        logger.fatal "GH GraphQL query data is missing"
        abort
      elsif response.body.include?(RATE_LIMITED)
        sleep 300
        return false
      end

      true
    end

    # Run a GraphQL GitHub query
    #
    # @param query [string] the query to send to GitHub
    # @return [string] the returned data from GitHub
    def run_query(query)
      got_data = false
      count = 0

      until got_data
        count += 1
        response = query_github_api(query)
        got_data = is_response_okay(response)
        if count > 5
          logger.fatal "GH GraphQL query error"
          abort
        end
      end
      response.body
    end

    private

    # Form and call the GraphQL GitHub query
    #
    # @param body [string] the query data to send to GitHub
    # @return [Net::HTTPResponse] the reply data from GitHub
    def query_github_api(body)
      json = {query: body}.to_json
      headers = {"Authorization" => "bearer #{@github_token}"}
      uri = URI.parse(GRAPHQL_URI)
      Net::HTTP.post(uri, json, headers)
    end
  end
end