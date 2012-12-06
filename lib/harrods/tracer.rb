module Harrods
  class Tracer

    def initialize(db)
      @db = db
    end

    def record(key, &block)
      start_ram, start_objects = begin_analysis
      gc_runs, gc_time         = nil, nil
      begin
        yield
      ensure
        used_ram, used_objects, gc_runs, gc_time = end_and_log_analysis(key, start_ram, start_objects)
        @db.flush!
      end
      return [used_ram, used_objects, gc_runs, gc_time]
    end


    private
    def begin_analysis
      GC.enable
      GC::Profiler.enable
      GC::Profiler.clear
      GC.enable_stats
      GC.clear_stats
      start_ram, start_objects = GC.allocated_size.to_i, ObjectSpace.allocated_objects.to_i
      return [start_ram, start_objects]
    end

    def end_and_log_analysis(key, start_ram, start_objects)
      used_ram, used_objects = (GC.allocated_size.to_i - start_ram), (ObjectSpace.allocated_objects.to_i - start_objects)
      gc_runs, gc_time       = GC.collections, GC::Profiler.total_time
      log_to_db(key, used_ram, used_objects, gc_runs, gc_time)
      return [used_ram, used_objects, gc_runs, gc_time]
    end

    def log_to_db(key, used_ram, used_objects, gc_runs, gc_time)
      token = ("%.6f" % Time.new.to_f).gsub(".", "")
      @db.hmset    token, {ram: used_ram, objects: used_objects, gc_runs: gc_runs, gc_time: gc_time}
      @db.sadd     key, token
      update_stats key
    end

    def update_stats(key)
      requests = @db.hmgetall(@db.get(key))
      rams, objects, gc_runs, gc_times = [], [], [], []
      requests.each do |key, val|
        rams      << val[:ram]
        objects   << val[:objects]
        gc_runs   << val[:gc_runs]
        gc_times  << val[:gc_time]
      end
      ave_ram     = rams.inject(:+).to_f / requests.length
      ave_objects = objects.inject(:+).to_f / requests.length
      ave_gc_run  = gc_runs.inject(:+).to_f / requests.length
      ave_gc_time = gc_times.inject(:+).to_f / requests.length
      @db.hmset "stats::#{key}", {
          ram:     ave_ram,
          objects: ave_objects,
          gc_runs: ave_gc_run,
          gc_time: ave_gc_time
      }
    end
  end
end