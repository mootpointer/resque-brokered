require 'rubygems'
require 'bundler'

require "rspec/core/rake_task" # RSpec 2.0

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

task :default => :spec
