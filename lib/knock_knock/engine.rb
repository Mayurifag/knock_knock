module KnockKnock
  class Engine < ::Rails::Engine
    isolate_namespace KnockKnock
    # config.autoload_paths << File.expand_path("lib/generators/knock_knock", __dir__)
    # config.eager_load_paths += Dir["#{config.root}/lib/**/"]
    config.generators.api_only = true
  end
end
