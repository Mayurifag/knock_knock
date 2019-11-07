module KnockKnock
  class Engine < ::Rails::Engine
    isolate_namespace KnockKnock

    config.generators.api_only = true
  end
end
