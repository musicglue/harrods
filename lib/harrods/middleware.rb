require 'slim'

module Harrods
  class Middleware

    TOOLBAR_PATH = File.expand_path("../../../templates/toolbar.slim", __FILE__)

    def initialize(app)
      @app = app
    end

    def call(env)
      @status, @headers, @response, @ram, @objects = nil, nil, nil
      if env['REQUEST_URI'].split("/")[1]  == "assets"
        @status, @headers, @response = @app.call(env)
      else
        @ram, @objects = Harrods.how_much? do
          @status, @headers, @response = @app.call(env)
        end
      end
      @output = inject_this_shizzle
      [@status, @headers, response]
    end

    def response
      [@output]
    end

    private
    def inject_this_shizzle
      full_body = @response.body.join
      full_body.gsub! /<\/body>/, toolbar + "</body>"

      @headers['Content-Length'] = "#{full_body.size}"
      return full_body
    end

    def toolbar
      Slim::Template.new(TOOLBAR_PATH, {}).render()
    end
  end
end