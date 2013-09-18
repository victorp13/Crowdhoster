# Be sure to restart your server when you modify this file.

Crowdhoster::Application.config.session_store :cookie_store, 
  key: '_Crowdhoster_session', 
  domain: :all, 
  tld_length: 2

# Redefine DeviseLoginCookie to use custom options
session_options = Proc.new do
  @session_options ||= Rails.configuration.session_options
  @session_options = @session_options.slice(:path, :domain, :secure, :httponly)
  @session_options.merge!({domain: :all, httponly: true})
  @session_options.merge!({secure: true}) if Rails.env.production?
  return @session_options
end
DeviseLoginCookie::Cookie.send(:define_method, :cookie_options, session_options)
DeviseLoginCookie::Cookie.send(:private, :cookie_options)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Crowdhoster::Application.config.session_store :active_record_store
