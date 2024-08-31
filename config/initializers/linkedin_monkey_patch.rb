module OmniAuth
  module Strategies
    class LinkedIn
      option :client_options, {
        :site => 'https://api.linkedin.com',
        :authorize_url => 'https://www.linkedin.com/oauth/v2/authorization?response_type=code',
        :token_url => 'https://www.linkedin.com/oauth/v2/accessToken',
        :token_method => :post_with_query_string
      }
    end
  end
end