require 'redis'
require 'redis-namespace'

module Harrods
  module RedisClient
    
    class << self
      def average_log(request, ram, objects)
        current = recover_hash request
        current = process_averages current, ram, objects
        update_hash request, current
      end
      
      def get_average_for(request)
        return recover_hash request
      end
      
      def client
        @client ||= Redis::Namespace.new(Harrods.config.redis_namespace, redis: redis)
      end
      
      def redis
        @redis ||= Redis.new(url: Harrods.config.redis_connection_string)
      end
      
      def initialize_hash_from_redis(out)
        out["ram"]        ||= 0
        out["objects"]    ||= 0
        out["iterations"] ||= 0
        out.each{ |k, v| out[k] = v.to_i }
        return out      
      end
      
      private
      def process_averages(current, ram, objects)
        total_ram     = current["ram"]      * current["iterations"] + ram
        total_objects = current["objects"]  * current["iterations"] + objects
        current["iterations"]  += 1
        current["ram"]          = total_ram / current["iterations"]
        current["objects"]      = total_objects / current["iterations"]
        current["latest_hit"]   = DateTime.now.to_i
        return current
      end  
      
      def recover_hash(request)
        out = client.hgetall request
        out = initialize_hash_from_redis(out)
        return out
      end
      
      def update_hash(request, hash)
        client.sadd  "averages", request
        client.hmset request, hash.to_a.flatten
      end
    end
    
  end
end