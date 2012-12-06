require 'daybreak'

module Harrods
  class Database

    attr_accessor :db

    def initialize(path)
      @db = Daybreak::DB.new path
    end

    def set(key, value)
      @db[key] = value
    end

    def get(key)
      @db[key]
    end

    def del(key)
      @db[key] = nil
    end

    def sadd(key, *values)
      terms = @db[key] || []
      values.each do |val|
        if val.is_a?(Array)
          val.each{ |v| terms << v unless terms.include?(v) }
        else
          terms << val unless terms.include?(val)
        end
      end
      @db[key] = terms
    end

    def hmset(key, hash)
      @db[key] = hash
    end

    def hset(key, field, value)
      @db[key] ||= {}
      @db[key][field] = value
    end

    def hget(key, field)
      @db[key].nil? ? nil : @db[key][field]
    end

    def hgetall(key)
      @db[key]
    end

    def hmgetall(*keys)
      out = {}
      keys.each do |key|
        if key.is_a?(Array)
          key.each{ |k| out[k] = @db[k] }
        else
          out[key] = @db[key]
        end
      end
      out.each{ |key, val| out.delete(key) unless val }
      return out
    end

    def smembers(key)
      @db[key]
    end

    def reload!
      @db.read!
    end

    def flush!
      @db.flush!
    end

    class << self
      def load
        path = Harrods.config.database_path
        new(path)
      end
    end
  end
end