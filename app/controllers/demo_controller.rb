require "open-uri"

class DemoController < ApplicationController
  before_action :authenticate_user!

  # HACK: Disable CSRF token authenticity verification
  skip_before_action :verify_authenticity_token, only: [
    :post_api_create,
    :post_api_execute,
    :post_api_request,
    :get_api_read,
    :get_api_read2,
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
  end

  def post_api_create
    data = JSON.parse(request.body.read)
    name = data["name"]

    ActiveRecord::Base.connection.execute("INSERT INTO pets (pet_name, owner) VALUES ('#{name}', 'Aikido Security')")

    render plain: 1
  end

  # Shell injection

  def post_api_execute
    data = JSON.parse(request.body.read)
    command = data["userCommand"]

    result = system(command)

    render plain: result
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
  end

  def post_api_request2
    data = JSON.parse(request.body.read)
    url_string = data["url"]
    content = URI.open(url_string).read
    render plain: content
  end


  def post_api_request_different_port
    begin
      data = JSON.parse(request.body.read)
      url_string = data["url"]
      port = data["port"]
      url_string = url_string.sub(/:\d+/, ":#{port}")
      content = URI.open(url_string).read
      render plain: content
    rescue => e
      if e.is_a?(Aikido::Zen::SSRFDetectedError)
        render plain: "blocked by aikido", status: :internal_server_error
      else
        # 400 status code
        head :bad_request and return
      end
    end
  end

  def post_api_stored_ssrf
    begin
      url = 'http://evil-stored-ssrf-hostname/latest/api/token'
      content = URI.open(url).read
      render plain: content
    rescue => e
      if e.is_a?(Aikido::Zen::SSRFDetectedError)
        render plain: "blocked by aikido", status: :internal_server_error
      else
        # 400 status code
        head :bad_request and return
      end
    end
  end

  def get_api_read
    path = params[:path]

    # Avoid using File.join, so that, if raised, Aikido::Zen::PathTraversalError
    # is raised by File.read.
    file_path = Pathname.new(PUBLIC_SHARED_ASSETS) + path
  
    puts "file_path: #{file_path}"
    content = File.read(file_path)

    render plain: content
  rescue Errno::ENOENT, Errno::EACCES, Errno::EISDIR
    # status code should be 500
    head :internal_server_error and return
  end

  def get_api_read2
    path = params[:path]
 
    file_path = File.join(PUBLIC_SHARED_ASSETS, path)
    puts "file_path: #{file_path}"
    content = File.read(file_path)

    render plain: content
  rescue Errno::ENOENT, Errno::EACCES, Errno::EISDIR
    # status code should be 500
    head :internal_server_error and return
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
