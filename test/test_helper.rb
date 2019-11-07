# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

require "bcrypt"

require "minitest/retry"
Minitest::Retry.use!

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  # ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

# Make sure global configuration is reset before every tests
# to avoid order dependent failures.
class ActiveSupport::TestCase
  setup :reset_configuration

  private

  def reset_configuration
    KnockKnock.token_signature_algorithm = "HS256"
    KnockKnock.token_secret_signature_key = -> { Rails.application.credentials.fetch(:secret_key_base) }
    KnockKnock.token_public_key = nil
    KnockKnock.token_audience = nil
    KnockKnock.token_lifetime = 1.day
  end
end
