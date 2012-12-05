module Harrods
  class Configuration
    attr_accessor :redis_connection_string, :redis_namespace
    
    def initialize
      @redis_connection_string  = "redis://localhost:6379/0"
      @redis_namespace          = "harrods"
    end
  end
end