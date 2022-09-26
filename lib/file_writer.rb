class FileWriter
  attr_reader :results

  def initialize(params)
    @results = params.fetch(:results)
  end

  def write_data
    write_public_data
    write_private_data
  end

  private

  def write_public_data
    public_repos = results.reject { |r| r.dig(:is_private) == true }

    if public_repos.length > 0
      public_repos_json = {
        data: public_repos
      }.to_json

      File.write("public_data.json", public_repos_json)
    end
  end

  def write_private_data
    private_repos = results.reject { |r| r.dig(:is_private) == false }

    if private_repos.length > 0
      private_repos_json = {
        data: private_repos
      }.to_json

      File.write("private_data.json", private_repos_json)
    end
  end
end
