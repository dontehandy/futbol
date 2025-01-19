require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'rspec'
require_relative '../lib/stat_tracker'
require_relative '../lib/game'
require_relative '../lib/team'
require 'pry'
require 'csv'

RSpec.configure do |config|
  config.before(:suite) do
    SimpleCov.start
  end
  # Additional RSpec configuration can go here
end
