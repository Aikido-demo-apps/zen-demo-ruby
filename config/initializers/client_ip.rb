if Rails.application.config.respond_to?(:zen)
  Rails.application.config.zen.client_ip_header = "FLY_CLIENT_IP"
end
