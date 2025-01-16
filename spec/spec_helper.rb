require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'rspec'
require './lib/stat_tracker'
require 'pry'
require 'csv'

RSpec.configure do |config|
  config.before(:suite) do
    SimpleCov.start
  end
  # Additional RSpec configuration can go here
end


# open coverage/index.html after running rspec