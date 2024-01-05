require 'database_cleaner/active_record'
require "dotenv/load"
require 'pry'
require 'pry-byebug'
require 'amazing_print'
require 'rspec'

Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
Pry.commands.alias_command 'f', 'finish'

ENV['RUBY_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'


# root = Pathname.new(File.expand_path('..', __dir__))
# environment = File.join(root, 'config/environment.rb')
# require environment

# DatabaseCleaner[:active_record].strategy = :transaction

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.fails.log'
  config.before(:suite) do |sss|
  end
  config.before(:each) do |t|
    # DatabaseCleaner.start
  end
  config.after(:each) do
    # DatabaseCleaner.clean
  end
end