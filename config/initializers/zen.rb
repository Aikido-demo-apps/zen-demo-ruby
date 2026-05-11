if Rails.application.config.respond_to?(:zen)
  zen = Rails.application.config.zen

  zen.client_ip_header = "HTTP_FLY_CLIENT_IP"

  zen.idor_protection_enabled = true
  zen.idor_tenant_column_name = "tenant_id"
  zen.idor_excluded_table_names = ["pg_type"]
end
