module CodebreakerWeb
  module ResponseHelper
    def send_respond(view, **args)
      Rack::Response.new(render(view, **args))
    end

    def render(template, **args)
      Tilt.new(template_path(template)).render(Object.new, **args)
    end

    def template_path(template)
      File.expand_path("../../../../views/#{template}.html.erb", __FILE__)
    end

    def redirect(path)
      Rack::Response.new { |response| response.redirect(path) }
    end
  end
end
