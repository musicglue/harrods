module Harrods
  class BasicMiddleware

    def initialize(app)
      @db     = Harrods::Database.new Rails.root.join("db","harrods.db")
      @logger = Harrods::Logger.new
      @app    = app
    end

    def call(env)
      tracer = Harrods::Tracer.new(@db)
      status, headers, response, output, ram, objects, gc_runs, gc_time = nil, nil, nil, nil, nil, nil, nil
      if env['ORIGINAL_FULLPATH'].split("/")[1]  == "assets"
        status, headers, response = @app.call(env)
        [status, headers, response]
      else
        ram, objects, gc_runs, gc_time = tracer.record(env['ORIGINAL_FULLPATH']) do
          status, headers, response = @app.call(env)
        end
        @logger.log(ram, objects, gc_runs, gc_time)
        [status, headers, response]
      end
    end
  end
end