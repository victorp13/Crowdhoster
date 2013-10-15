class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :load_settings, :set_default_mailer_host
  after_filter :store_location

  def load_settings
    @settings = Settings.find_by_id(1)

    if !@settings
      @settings = Settings.create
    end
  end

  def set_default_mailer_host
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
  end

  def store_location
    # store last url as long as it isn't an /account path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/account/
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def verify_admin
    if !current_user.admin?
      redirect_to root_url, :flash => { :notice => "You must be an admin to access that page" }
   end
  end

  def check_init
    if !@settings.initialized_flag
      if current_user
        # Create the Admin User
        current_user.update_attribute :admin, true

        # Set intiatilized flag to true
        @settings.update_attribute :initialized_flag, true

        # Set default reply_to_email to Admin User email
        @settings.update_attribute :reply_to_email, current_user.email

        # Create the Crowdtilt API Users
        begin
          Crowdtilt.sandbox
          sandbox_guest = {
            firstname: 'Crowdhoster',
            lastname: (Rails.configuration.crowdhoster_app_name + '-guest'),
            email: (Rails.configuration.crowdhoster_app_name + '-guest@crowdhoster.com')
          }
          sandbox_guest = Crowdtilt.post('/users', {user: sandbox_guest})

          sandbox_admin = {
            firstname: 'Crowdhoster',
            lastname: (Rails.configuration.crowdhoster_app_name + '-admin'),
            email: (Rails.configuration.crowdhoster_app_name + '-admin@crowdhoster.com')
          }
          sandbox_admin = Crowdtilt.post('/users', {user: sandbox_admin})
        rescue => exception
          @settings.update_attribute :initialized_flag, false
          sign_out current_user
          redirect_to new_user_registration_url, :flash => { :error => "An error occurred, please contact team@crowdhoster.com: #{exception.message}" }
          return
        else
          @settings.update_attribute :ct_sandbox_guest_id, sandbox_guest['user']['id']
          @settings.update_attribute :ct_sandbox_admin_id, sandbox_admin['user']['id']
        end


        # Put user back on admin area
        redirect_to admin_website_url, :flash => { :success => "Nice! Your app is now initialized." }
      else
        redirect_to new_user_registration_url, :flash => { :error => "App is not initialized" }
      end
    end
  end
end
