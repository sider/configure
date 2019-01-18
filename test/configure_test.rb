require "test_helper"

class ConfigureTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Configure::VERSION
  end
end
