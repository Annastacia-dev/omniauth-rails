Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
  {
    prompt: 'select_account'
  }
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
  {
    prompt: 'select_account'
  }
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end