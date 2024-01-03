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

# require files and apps
# module Config
#   def self.require_files(dir, extension = 'rb')
#     files = Dir["#{dir}/**/**/**/**/**/**"] # check 6 levels deep
#     files.select! { |f| f.match(%r{\.#{extension}$}) }
#     files.each { |f| require f }
#   end
# end

# helpers = File.join(root, 'lib/helpers')
# models = File.join(root, 'lib/models')
# services = File.join(root, 'lib/services')
# workers = File.join(root, 'lib/workers')

# Config.require_files(helpers)
# Config.require_files(models)
# Config.require_files(services)
# Config.require_files(workers)


Oj.default_options = { mode: :compat, symbol_keys: true, time_format: :ruby }

# ActiveRecord::Base.logger = Logger.new(STDOUT)
# LOGLEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze
# ActiveRecord::Base.logger.level = LOGLEVELS.index(ENV.fetch('LOG_LEVEL', 'DEBUG'))
# set :database, File.join(root, 'db/config.yml')
