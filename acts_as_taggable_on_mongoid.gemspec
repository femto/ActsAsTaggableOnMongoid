$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "acts_as_taggable_on_mongoid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "acts_as_taggable_on_mongoid"
  spec.version     = ActsAsTaggableOnMongoid::VERSION
  spec.authors     = ["femto"]
  spec.email       = ["femtowin@gmail.com"]
  spec.homepage    = "http://"
  spec.summary     = "Summary of ActsAsTaggableOnMongoid."
  spec.description = "Description of ActsAsTaggableOnMongoid."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails"

  spec.add_development_dependency "sqlite3"

  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'barrier'
  spec.add_development_dependency 'database_cleaner'
end
