require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class MITOAuth2 < OmniAuth::Strategies::OAuth2
      option :name, 'mit_oauth2'

      option :client_options, {
        site: "https://oidc.mit.edu",
        authorize_url: '/authorize',
        token_url: '/token'
      }

      uid { raw_info['sub'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get('/userinfo').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization('mit_oauth2', 'MITOAuth2')
