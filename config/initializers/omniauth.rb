require 'strategies/linkedin'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']

  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
    scope: 'public_profile,email', info_fields: 'id,name,email'

  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']

  provider :twitter2, ENV["TWITTER_CLIENT_ID"], ENV["TWITTER_CLIENT_SECRET"], callback_path: '/auth/twitter2/callback', scope: "tweet.read users.read", headers:{
    Authorization: "Basic #{Base64.strict_encode64("#{ENV["TWITTER_CLIENT_ID"]}:#{ENV["TWITTER_CLIENT_SECRET"]}")}"
  }

  provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], scope: 'r_liteprofile r_emailaddress'
end