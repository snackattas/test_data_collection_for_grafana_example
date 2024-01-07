require 'singleton'

# Singleton Class meant to be used in specs themselves, to write random data to the test data DB, for ad-hoc analysis
class RSpecDBFormatterAdHocData
  include Singleton

  def initialize
    @_data = {}
  end

  def add_data(hash)
    raise ArgumentError, "Arg to add_data '#{hash}' must be a Hash, cannot be a #{hash.class}" if !hash.is_a? Hash

    @_data = @_data.merge(hash)
  end

  def clear_data
    @_data = {}
  end

  def data
    @_data
  end
end
