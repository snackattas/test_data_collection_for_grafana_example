require 'singleton'

class RSpecDBFormatterAdHocData
    include Singleton

    def initialize
        @data = {}
    end

    def add_data(data)
        if !data.is_a? Hash
            raise ArgumentError.new("Arg to add_data '#{data}' must be a Hash, cannot be a #{data.class}")
        end
        @data = @data.merge(data)
    end

    def clear_data
        @data = {}
    end

    def get_data
        @data
    end
end