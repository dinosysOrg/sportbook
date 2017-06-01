module V1
  class DevicesApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    include ExceptionHandlers

    desc 'Store device token', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' }
    ]
    params do
      requires :user_id, type: Integer
      requires :token, type: String
      requires :platform, type: String
    end
    post 'devices/create' do
      Device.create(user_id: params[:user_id],
                    token: params[:token],
                    platform: params[:platform]&.downcase)
    end
  end
end
