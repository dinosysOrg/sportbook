class AuthApiController < ApplicationController
  before_action :set_long_term_token, :set_profile

  def create
    user = User.find_or_create_by(query_params) do |u|
      u.provider = 'facebook'
      u.uid = profile['id']
      u.name = profile['name']
      u.password = 'password'
    end
    user.facebook_uid = profile['id']
    user.facebook_credentials = long_term_token

    assign_header_token user
    render json: profile
  end

  private

  attr_reader :long_term_token, :profile

  def assign_header_token(user)
    token = user.create_new_auth_token
    token.each do |k, v|
      response.set_header(k, v)
    end
  end

  def query_params
    profile['email'] ? { email: profile['email'] } : { facebook_uid: profile['id'] }
  end

  def set_profile
    graph = Koala::Facebook::API.new(long_term_token['access_token'])
    @profile = graph.get_object('me?fields=id,name,email,gender')
  end

  def set_long_term_token
    facebook_oauth = Koala::Facebook::OAuth.new(ENV.fetch('APP_FACEBOOK_ID'),
                                                ENV.fetch('APP_SECRET_CODE'))
    short_term = params[:access_token]
    @long_term_token = facebook_oauth.exchange_access_token_info(short_term)
  end
end
