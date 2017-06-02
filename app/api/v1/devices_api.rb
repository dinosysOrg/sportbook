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
      requires :user_id, type: Integer, desc: 'User register push notification'
      requires :token, type: String, desc: 'Device token from mobile'
      requires :platform, type: String, desc: "Platform of device. Input value is 'iOS' or 'Android'"
    end
    post 'devices/create' do
      Device.create(user_id: params[:user_id],
                    token: params[:token],
                    platform: params[:platform])
    end
  end
end
