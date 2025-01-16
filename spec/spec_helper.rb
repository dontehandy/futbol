require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'rspec'
require './lib/stat_tracker'
require 'pry'
require 'csv'

RSpec.configure do |config|
  # Additional RSpec configuration can go here
end
