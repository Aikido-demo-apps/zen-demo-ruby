if Rails.application.config.respond_to?(:zen)
  zen = Rails.application.config.zen

  zen.client_ip_header = "HTTP_FLY_CLIENT_IP"
  zen.realtime_settings_updates_enabled = true
end
