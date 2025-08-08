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

  def track_current_user
    user_id = request.headers["user"]
    if user_id
      Aikido::Zen.track_user({
        id: user_id,
        name: "User #{user_id}"
      })
    end
  end
end
