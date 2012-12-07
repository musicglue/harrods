require 'colorize'

module Harrods
  class Logger
    include Presenter
    extend Presenter

    def initialize(colour=:red, destination=$stdout)
      @logger = destination
      @colour = colour
    end

    def log(ram, objects, gc_runs, gc_time)
      @logger.write "[HARRODS] RAM: #{present_storage_size(ram)}, OBJECTS: #{present_with_commas(objects)}, GC RUNS: #{gc_runs}, GC TIME: #{gc_time}\n".colorize(@colour)
    end

  end
end