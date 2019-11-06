require "rails/generators"

module KnockKnock
  # Creates a Knockknock token controller for the given entity
  # and add the corresponding routes.
  class TokenControllerGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    argument :entity_name, type: :string

    desc <<-DESC
      Creates a Knockknock token controller for the given entity
      and add the corresponding routes.
    DESC

    def copy_controller_file
      template "entity_token_controller.rb.erb",
        "app/controllers/#{entity_name.underscore}_token_controller.rb"
    end

    def add_route
      route "post :#{entity_name.underscore}_token, to: " \
        "'#{entity_name.underscore}_token#create'"
    end
  end
end
