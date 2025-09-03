module Middleware
  class FlyClientIp
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["HTTP_FLY_CLIENT_IP"].present?
        env["REMOTE_ADDR"] = env["HTTP_FLY_CLIENT_IP"]
      end

      @app.call(env)
    end
  end
end
