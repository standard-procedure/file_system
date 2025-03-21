module FileSystem
  class Engine < ::Rails::Engine
    isolate_namespace FileSystem

    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
  end
end
