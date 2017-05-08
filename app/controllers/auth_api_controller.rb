require 'koala'
class AuthApiController < ApplicationController
  before_action 'connect_facebook'

  def create
    @graph = Koala::Facebook::API.new(@long_token['access_token'])
    profile = @graph.get_object('me?fields=id,name,email,gender')
    new_user = User.create(email: profile['email'], password: 'password', provider: 'facebook', uid: profile['id'])
    token = new_user.create_new_auth_token

    token.each do |k, v|
      response.set_header(k, v)
    end

    render json: profile
  end

  private

  def connect_facebook
    @facebook_oauth ||= Koala::Facebook::OAuth.new(ENV.fetch('APP_FACEBOOK_ID'),
                                                   ENV.fetch('APP_SECRET_CODE'))
    @short_term = params[:access_token]
    @long_token = @facebook_oauth.exchange_access_token_info(@short_term)
  end
end
