Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Settings.environments.OmniAuth.facebook.facebook_app_id, Settings.environments.OmniAuth.facebook.facebook_secret
  provider :google_oauth2, Settings.environments.OmniAuth.google_oauth2.google_app_id, Settings.environments.OmniAuth.google_oauth2.google_secret
end