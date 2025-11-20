Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check, format: false

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker, format: false
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest, format: false

  # Defines the root path route ("/")
  root "demo#root", format: false

  # HACK: Bypasses Rails' conventions to implement flat endpoints

  get "/pages/index", to: "demo#get_index", format: false
  get "/pages/execute", to: "demo#get_execute", format: false
  get "/pages/create", to: "demo#get_create", format: false
  get "/pages/request", to: "demo#get_request", format: false
  get "/pages/read", to: "demo#get_read", format: false

  # Rate limiting

  get "/test_ratelimiting_1", to: "demo#get_test_ratelimiting_1", format: false
  get "/test_ratelimiting_2", to: "demo#get_test_ratelimiting_2", format: false

  # Bot blocking

  get "/test_bot_blocking", to: "demo#get_test_bot_blocking", format: false

  # User blocking

  get "/test_user_blocking", to: "demo#get_test_user_blocking", format: false

  # SQL injection

  get "/clear", to: "demo#get_clear", format: false
  get "/api/pets/", to: "demo#get_api_pets", format: false
  post "/api/create", to: "demo#post_api_create", format: false

  # Shell injection

  post "/api/execute", to: "demo#post_api_execute", format: false
  # post "/api/execute/<command>", to: "demo#post_api_execute_command" # Unused?

  # SSRF

  post "/api/request", to: "demo#post_api_request", format: false
  post "/api/request2", to: "demo#post_api_request2", format: false
  
  post "/api/request_different_port", to: "demo#post_api_request_different_port", format: false
  
  post "/api/stored_ssrf", to: "demo#post_api_stored_ssrf", format: false
  post "/api/stored_ssrf_2", to: "demo#post_api_stored_ssrf_2", format: false
  # Path traversal

  get "/api/read", to: "demo#get_api_read", format: false
  get "/api/read2", to: "demo#get_api_read2", format: false

  # AI usage

  post "/test_llm", to: "demo#post_test_llm", format: false

  # Serve static files from shared-assets/public/*
  get "/*path", to: "demo#get_path", format: false
end
