require_relative "lib/file_system/version"
Gem::Specification.new do |spec|
  spec.name        = "standard_procedure_file_system"
  spec.version     = FileSystem::VERSION
  spec.authors     = [ "Rahoul Baruah" ]
  spec.email       = [ "rahoulb@echodek.co" ]
  spec.homepage    = "https://theartandscienceofruby,com/"
  spec.summary     = "Standard Procedure: FileSystem"
  spec.description = "FileSystem"
  spec.license     = "LGPL"

  spec.metadata["allowed_push_host"] = "https://rubygems.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/standard_procedure"
  spec.metadata["changelog_uri"] = "https://github.com/standard_procedure"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3"
end
