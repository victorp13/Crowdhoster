class SessionsController < Devise::SessionsController
  skip_filter :check_initialized

protected

  def after_sign_in_path_for(resource)
    admin_website_path
  end

end
