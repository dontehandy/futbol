require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'rspec'
require './lib/stat_tracker'
require './lib/game'
require './lib/team'
require 'pry'
require 'csv'

RSpec.configure do |config|
  config.before(:suite) do
    SimpleCov.start
  end
  # Additional RSpec configuration can go here
end
