class DemoController < ApplicationController
  # HACK: Disable CSRF token authenticity verification
  skip_before_action :verify_authenticity_token, only: [
    :post_api_create,
    :post_api_execute,
    :post_api_request,
    :get_api_read,
    :post_test_llm
  ]

  def root
    send_shared_asset "index.html"
  end

  def get_create
    send_shared_asset "create.html"
  end

  def get_execute
    send_shared_asset "execute_command.html"
  end

  def get_request
    send_shared_asset "request.html"
  end

  def get_read
    send_shared_asset "read_file.html"
  end

  def get_test_ratelimiting_1
    render plain: "Request successful (Ratelimiting 1)"
  end

  def get_test_ratelimiting_2
    render plain: "Request successful (Ratelimiting 2)"
  end

  def get_test_bot_blocking
    render plain: "Hello World! Bot blocking enabled on this route."
  end

  def get_test_user_blocking
    user_id = request.headers["user"]
    render plain: "Hello User with id: #{user_id}"
  end

  # SQL injection

  def get_clear
    ActiveRecord::Base.connection.execute("DELETE FROM pets")
    render plain: "Cleared successfully."
  end

  def get_api_pets
    pets = []

    rows = ActiveRecord::Base.connection.execute("SELECT * FROM pets")

    rows.each do |row|
      pets << {
        "pet_id" => row["pet_id"].to_s,
        "name" => row["pet_name"].to_s,
        "owner" => row["owner"].to_s
      }
    end

    render json: pets
  rescue
    head :internal_server_error
  end

  def post_api_create
    data = JSON.parse(request.body.read)
    name = data["name"]

    ActiveRecord::Base.connection.execute("INSERT INTO pets (pet_name, owner) VALUES ('#{name}', 'Aikido Security')")

    render plain: 1
  rescue Aikido::Zen::SQLInjectionError
    head :internal_server_error
  rescue
    head :bad_request and return
  end

  # Shell injection

  def post_api_execute
    data = JSON.parse(request.body.read)
    command = data["userCommand"]

    result = system(command)

    render plain: result
  rescue Aikido::Zen::ShellInjectionError
    head :internal_server_error
  rescue
    head :bad_request and return
  end

  # SSRF

  def post_api_request
    data = JSON.parse(request.body.read)
    url_string = data["url"]
    uri = URI.parse(url_string)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.read_timeout = 10 # seconds
    http.open_timeout = 10 # seconds

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    render plain: response.code
  rescue Aikido::Zen::SSRFDetectedError
    head :internal_server_error
  rescue
    head :bad_request and return
  end

  def get_api_read
    path = params[:path]

    # Avoid using File.join, so that, if raised, Aikido::Zen::PathTraversalError
    # is raised by File.read.
    file_path = BLOGS_SHARED_ASSETS.to_s + "/#{path}"

    content = File.read(file_path)

    render plain: content
  rescue Aikido::Zen::PathTraversalError
    head :internal_server_error
  rescue Errno::ENOENT, Errno::EACCES, Errno::EISDIR
    head :not_found and return
  rescue
    head :bad_request and return
  end

  def post_test_llm
    render plain: "Demo feature not implemented"
  end

  def get_path
    path = params[:path]

    if path.blank?
      head :bad_request and return
    end

    file_path = PUBLIC_SHARED_ASSETS.join(path)

    # Prevent directory traversal
    unless file_path.realpath.to_s.start_with?(PUBLIC_SHARED_ASSETS.to_s)
      head :forbidden and return
    end

    send_file file_path, disposition: "inline"
  rescue Errno::ENOENT, Errno::EACCES, Errno::EISDIR
    head :not_found
  end
end
