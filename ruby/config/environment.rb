require 'active_record'
require 'dotenv'
require 'enumerize'
require 'logger'
require 'oj'
require 'rack'
require 'sinatra/activerecord'

ENV['RACK_ENV'] ||= 'development'

root = Pathname.new(File.expand_path('..', __dir__))
Dotenv.load(root.join('.env'))

require_relative '../lib/models'

Oj.default_options = { mode: :compat, symbol_keys: true, time_format: :ruby }
set :run, false

# ActiveRecord::Base.logger = Logger.new(STDOUT)
# LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze
# ActiveRecord::Base.logger.level = LOGLEVELS.index(ENV.fetch('LOG_LEVEL', 'DEBUG'))
