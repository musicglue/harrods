require "harrods/version"
require "harrods/redis_client"
require "harrods/configuration"
require "harrods/presenter"
require "harrods/middleware"
require "harrods/database"
require "harrods/tracer"
require "harrods/basic_middleware"
require "harrods/logger"

module Harrods
  extend Presenter
  
  class << self
    attr_accessor :config
  end
  
  def self.configure(&block)
    self.config ||= Configuration.new
    yield(config)
  end
  
  def self.how_much?(&block)
    start_ram, start_objects = begin_analysis
    used_ram, used_objects = nil, nil
    begin
      yield
    ensure
      used_ram, used_objects = end_analysis(start_ram, start_objects)
      log(used_ram, used_objects)
    end
    return [used_ram, used_objects]
  end
  
  def self.personalised_service(request, &block)
    start_ram, start_objects = begin_analysis
    used_ram, used_objects   = nil, nil
    begin
      yield
    ensure
      used_ram, used_objects = end_analysis(start_ram, start_objects)
      RedisClient.average_log request, used_ram, used_objects
      log(used_ram, used_objects)
      report_average(request)
    end
    return [used_ram, used_objects]
  end
  
  def self.for_your_pleasure(request, type="average")
    stats = RedisClient.send("#{type}_stats", request)
    puts stats
  end
  

  
  def self.report_average(request)
    average = RedisClient.get_average_for(request)
    log(average["ram"], average["objects"], :average)
  end
  
  def self.log(used_ram, used_objects, type=:log)
    puts "\e[#{35}m#{message(used_ram, used_objects, type)}\e[0m"
  end
  
  def self.message(ram, objects, type)
    case type
    when :log
      "[HARRODS::DEBUG] Instantiated: #{present_with_commas(objects)} Objects, using #{present_storage_size(ram)} of Heap Size"
    when :average
      "[HARRODS::AVERAGE] Average for call: #{present_with_commas(objects)} Objects, using  #{present_storage_size(ram)} of Heap Size"
    end
  end

end
