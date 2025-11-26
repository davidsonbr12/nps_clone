class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_admin!
    unless current_user&.admin?
      # Redirect to the root path or display an unauthorized message
      redirect_to root_path, alert: "You are not authorized to access that page."
    end
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
