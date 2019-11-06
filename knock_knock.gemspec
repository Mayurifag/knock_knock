$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "knock_knock/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "knock_knock"
  spec.version     = KnockKnock::VERSION
  spec.authors     = ["Mayurifag"]
  spec.email       = ["farazeus@gmail.com"]
  spec.homepage    = "https://github.com/Mayurifag/knock_knock"
  spec.summary     = "Summary of KnockKnock."
  spec.description = "Description of KnockKnock."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.1"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "standard"
end
