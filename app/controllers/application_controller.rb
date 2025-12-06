class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  PUBLIC_SHARED_ASSETS = Rails.root.join("shared-assets", "public")

  BLOGS_SHARED_ASSETS = Rails.root.join("shared-assets", "blogs")

  def send_shared_asset(*path_parts)
    file_path = Rails.root.join("shared-assets", *path_parts)
    send_file file_path, disposition: "inline"
  end

  def authenticate_user!
    if request.headers["user"]
      Aikido::Zen.set_user({
        id: request.headers["user"]
      })
    elsif request.headers["x-user-id"] && request.headers["x-user-name"]
      Aikido::Zen.set_user({
        id: request.headers["x-user-id"],
        name: request.headers["x-user-name"]
      })
    end
  end
end
