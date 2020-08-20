module CodebreakerWeb
  module DataManagementHelper
    def get_param(param)
      @request.params[param]
    end

    def session_die
      @request.session.clear
    end

    def session_param(param)
      @request.session[param]
    end
  end
end
