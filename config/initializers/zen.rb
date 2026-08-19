if Rails.application.config.respond_to?(:zen)
  zen = Rails.application.config.zen

  zen.realtime_settings_updates_enabled = true
end
