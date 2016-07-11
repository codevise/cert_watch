$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cert_watch/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cert_watch"
  s.version     = CertWatch::VERSION
  s.authors     = ["Tim Fischbach"]
  s.email       = ["tfischbach@codevise.de"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CertWatch."
  s.description = "TODO: Description of CertWatch."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.6"

  s.add_development_dependency "sqlite3"
end
