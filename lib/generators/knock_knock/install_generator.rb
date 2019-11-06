require_dependency "rails/generators"

module KnockKnock
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    desc "Creates a KnockKnock initializer."

    TEMPLATE_FILENAME = "knock_knock.rb".freeze

    def copy_initializer
      template TEMPLATE_FILENAME, app_controller_filepath
    end

    private

    def app_controller_filepath
      "config/initializers/#{TEMPLATE_FILENAME}"
    end
  end
end
