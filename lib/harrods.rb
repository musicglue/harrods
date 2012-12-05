require "harrods/version"

module Harrods
  def self.how_much?(&block)
    GC.enable
    GC.enable_stats
    start_ram, start_objects = GC.allocated_size, ObjectSpace.allocated_objects
    begin
      yield
    ensure
      puts "[STACK ANALYSIS] Objects Created: #{ObjectSpace.allocated_objects - start_objects}, Memory Used: #{GC.allocated_size - start_ram}"
    end
  end
end
