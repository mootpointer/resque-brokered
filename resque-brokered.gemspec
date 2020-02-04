
Gem::Specification.new do |s|
  s.name        = "resque-brokered"
  s.version     = "0.3.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Harvey", "James Sadler"]
  s.email       = ["andrew@mootpointer.com", "freshtonic@gmail.com"]
  s.homepage    = "https://github.com/mootpointer/resque-brokered"
  s.summary     = "Resque plugin to add some broker logic to picking jobs up off queues"
  s.description = "Allow resque to serialize consumption from queues based on a key."
  s.license     = 'BSD'

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency 'resque', '>= 1.20', '< 2.1'
  s.add_runtime_dependency 'redis'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~>2.0'
  s.add_development_dependency 'yajl-ruby'

  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
end
