require_relative "../lib/constants"

# Strings used within the tests
module TestConstants
  include Constants

  TEST_USER = "someuser"
  CATCH_ERROR = "catch error"
  TEST_REPO_NAME = "test-repo"
  TEST_URL = "#{GH_API_URL}/#{TEST_REPO_NAME}/issues"
  REPO_URL = "#{GH_ORG_URL}/#{TEST_REPO_NAME}"
  BODY = "abc"
end
