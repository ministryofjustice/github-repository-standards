require_relative "../lib/constants"
require "test_constants"

module TestHelpers
  include TestConstants
  include Constants

  def test_equal(value, expected_value)
    expect(value).to eq(expected_value)
  end

  def test_not_equal(value, expected_value)
    expect(value).not_to eq(expected_value)
  end
end
