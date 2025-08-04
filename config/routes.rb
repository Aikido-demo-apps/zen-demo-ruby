Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "demo#root"

  # HACK: Bypasses Rails' conventions to implement flat endpoints

  get "/pages/index", to: "demo#get_index"
  get "/pages/execute", to: "demo#get_execute"
  get "/pages/create", to: "demo#get_create"
  get "/pages/request", to: "demo#get_request"
  get "/pages/read", to: "demo#get_read"

  # Rate limiting

  get "/test_ratelimiting_1", to: "demo#get_test_ratelimiting_1"
  get "/test_ratelimiting_2", to: "demo#get_test_ratelimiting_2"

  # Bot blocking

  get "/test_bot_blocking", to: "demo#get_test_bot_blocking"

  # User blocking

  get "/test_user_blocking", to: "demo#get_test_user_blocking"

  # SQL injection

  get "/clear", to: "demo#get_clear"
  get "/api/pets/", to: "demo#get_api_pets"
  post "/api/create", to: "demo#post_api_create"

  # Shell injection

  post "/api/execute", to: "demo#post_api_execute"
  # post "/api/execute/<command>", to: "demo#post_api_execute_command" # Unused?

  # SSRF

  post "/api/request", to: "demo#post_api_request"
  post "/api/request2", to: "demo#post_api_request2"

  # Path traversal

  get "/api/read", to: "demo#get_api_read"
  get "/api/read2", to: "demo#get_api_read2"

  # AI usage

  post "/test_llm", to: "demo#post_test_llm"

  # Serve static files from shared-assets/public/*
  get "/*path", to: "demo#get_path", format: false
end
