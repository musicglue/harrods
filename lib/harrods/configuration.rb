module Harrods
  class Configuration
    attr_accessor :redis_connection_string, :redis_namespace, :database_path
    
    def initialize
      @redis_connection_string  = "redis://localhost:6379/0"
      @redis_namespace          = "harrods"
      @database_path            = "Users/john/Workspace/testapp/.harrods/development.db"
    end
  end
end