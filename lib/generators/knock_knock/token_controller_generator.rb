require_dependency "rails/generators"

module KnockKnock
  # Creates a Knockknock token controller for the given entity
  # and add the corresponding routes.
  class TokenControllerGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    argument :entity_name, type: :string

    TEMPLATE_FILENAME = "entity_token_controller.rb.erb".freeze

    desc <<-DESC
      Creates a Knockknock token controller for the given entity and add the
      corresponding routes.
    DESC

    def copy_controller_file
      template TEMPLATE_FILENAME, app_controller_filepath
    end

    def add_route
      route "post :#{undescored_name}_token, to: '#{undescored_name}_token#create'"
    end

    private

    def undescored_name
      @undescored_name ||= entity_name.underscore
    end

    def app_controller_filepath
      "app/controllers/#{undescored_name}_token_controller.rb"
    end
  end
end
