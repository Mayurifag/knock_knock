require "rails/generators"

module KnockKnock
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Creates a KnockKnock initializer."

    def copy_initializer
      template "knock_knock.rb", "config/initializers/knock_knock.rb"
    end
  end
end
