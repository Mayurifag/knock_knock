# require "rails/generators/test_case"
require "test_helper"
require "generators/knock_knock/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests KnockKnock::InstallGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "Assert all files are properly created" do
    run_generator
    assert_file "config/initializers/knock_knock.rb"
  end
end
