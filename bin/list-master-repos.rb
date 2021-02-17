#!/usr/bin/env ruby

# Script to list repositories in the ministryofjustice organisation whose names
# match a regular expression, and whose default branch is "master"

require "json"
require "net/http"
require "uri"
require "octokit"

require_relative "../lib/github_graph_ql_client"
require_relative "../lib/repository_lister"
require_relative "../lib/repository_report"

############################################################

params = {
  organization: ENV.fetch("ORGANIZATION"),
  regexp: Regexp.new(ENV.fetch("REGEXP")),
  team: ENV.fetch("TEAM"),
  github_token: ENV.fetch("GITHUB_TOKEN")
}

repositories = RepositoryLister.new(params)
  .repository_names
  .inject([]) do |arr, repo_name|
    report = RepositoryReport.new(params.merge(repo_name: repo_name)).report
    arr << report
end

repositories.filter { |report| report.fetch(:default_branch) == "master" }.each { |report| puts report.fetch(:name) }
