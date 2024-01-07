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

require_relative File.join(root, 'lib', 'models')

Oj.default_options = { mode: :compat, symbol_keys: true, time_format: :ruby }
ActiveRecord::Base.logger = Logger.new($stdout)
LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze
ActiveRecord::Base.logger.level = :INFO
