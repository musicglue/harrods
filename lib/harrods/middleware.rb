require 'erubis'

module Harrods
  class Middleware
    include Presenter

    TOOLBAR_PATH = File.expand_path("../../../templates/toolbar.erb", __FILE__)
    TOOLBAR      = File.read(TOOLBAR_PATH)
    TOOLBAR_ERB  = Erubis::FastEruby.new(TOOLBAR)

    def initialize(app)
      @db  = Harrods::Database.load
      @app = app
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
        headers, output = inject_this_shizzle(env['ORIGINAL_FULLPATH'], response, headers, ram, objects, gc_runs, gc_time)
        [status, headers, [output]]
      end
    end

    private
    def inject_this_shizzle(path, response, headers, ram, objects, gc_runs, gc_time)
      full_body = response.body.join
      full_body.gsub! /<\/body>/, render_toolbar(path, ram, objects, gc_runs, gc_time) + "</body>"
      headers["Etag"] = ""
      headers["Connection"] = "close"
      headers["Cache-Control"] = "no-cache"
      headers['Content-Length'] = "#{full_body.size}"
      return [headers, full_body]
    end

    def render_toolbar(path, ram_use, objects_count, gc_runs, gc_time)
      ram_formatted     = present_storage_size(ram_use)
      objects_formatted = present_with_commas(objects_count)
      stats             = @db.get "stats::#{path}"
      if stats
        stats[:ram_formatted]     = present_storage_size(stats[:ram].to_i)
        stats[:objects_formatted] = present_with_commas(stats[:objects].to_i)
      end
      raw_data, raw_ram_usage       = @db.hmgetall(@db.get(path)), []
      raw_data.each do |key, val|
        raw_ram_usage << val[:ram]
      end
      TOOLBAR_ERB.evaluate(ram: ram_formatted, objects: objects_formatted, stats: stats, raw_ram_usage: raw_ram_usage)
    end
  end
end