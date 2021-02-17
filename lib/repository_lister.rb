class RepositoryLister < GithubGraphQlClient
  attr_reader :organization, :regexp

  PAGE_SIZE = 100

  def initialize(params)
    @organization = params.fetch(:organization)
    @regexp = params.fetch(:regexp)
    super(params)
  end

  # Returns a list of repository names which match `regexp`
  def repository_names
    list_repos
      .select { |repo| repo["name"] =~ regexp }
      .map { |repo| repo["name"] }
  end

  private

  # TODO:
  #   * figure out a way to only fetch cloud-platform-* repos
  #   * de-duplicate the code
  #   * filter out archived repos
  #   * filter out disabled repos
  #
  def list_repos
    repos = []
    end_cursor = nil

    data = get_repos(end_cursor)
    repos = repos + data.fetch("nodes")
    next_page = data.dig("pageInfo", "hasNextPage")
    end_cursor = data.dig("pageInfo", "endCursor")

    while next_page do
      data = get_repos(end_cursor)
      repos = repos + data.fetch("nodes")
      next_page = data.dig("pageInfo", "hasNextPage")
      end_cursor = data.dig("pageInfo", "endCursor")
    end

    repos.reject { |r| r.dig("isArchived") || r.dig("isDisabled") }
  end

  def get_repos(end_cursor = nil)
    json = run_query(
      body: repositories_query(end_cursor),
      token: github_token
    )

    JSON.parse(json).dig("data", "organization", "repositories")
  end

  # TODO: it should be possible to exclude disabled/archived repos in this
  # query, but I don't know how to do that yet, so I'm just fetching everything
  # and throwing away the disabled/archived repos later. We should also be able
  # to only fetch repos whose names match the pattern we're interested in, at
  # this stage.
  def repositories_query(end_cursor)
    after = end_cursor.nil? ? "" : %[, after: "#{end_cursor}"]
    %[
    {
      organization(login: "#{organization}") {
        repositories(first: #{PAGE_SIZE} #{after}) {
          nodes {
            id
            name
            isLocked
            isArchived
            isDisabled
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
    ]
  end
end
