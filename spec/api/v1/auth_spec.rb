describe 'Auth' do
  describe 'signing up' do
    it 'creates user' do
      post '/api/v1/auth', params: { email: 'zi@dinosys.com', password: 'password', password_confirmation: 'password' }

      expect(response.status).to eq(200)

      user = User.find_by(email: 'zi@dinosys.com')
      expect(user.valid_password?('password')).to be true

    end

    context 'when email already exists' do
      it 'returns error' do
        create(:user, email: 'zi@dinosys.com')
        post '/api/v1/auth', params: { email: 'zi@dinosys.com', password: 'password', password_confirmation: 'password' }

        expect(response.status).to eq(422)
        expect(json_response[:errors][:email]).to include('has already been taken')
      end
    end

    context 'when email is invalid' do
      it 'returns error' do
        post '/api/v1/auth', params: { email: 'zi@dinosys.', password: 'password', password_confirmation: 'password' }

        expect(response.status).to eq(422)
        expect(json_response[:errors][:email]).to include('is not an email')
      end
    end

    context 'when passwords mismatch' do
      it 'returns error' do
        post '/api/v1/auth', params: { email: 'zi@dinosys.com', password: 'password', password_confirmation: 'pass' }

        expect(response.status).to eq(422)
        expect(json_response[:errors][:password_confirmation]).to include("doesn't match Password")
      end
    end
  end

  describe 'signing in' do
    context 'signin to an existing user' do
      it 'returns token' do
        user = create(:user, email: 'zi@dinosys.com', password: 'password')
        user.confirm

        post '/api/v1/auth/sign_in', params: { email: 'zi@dinosys.com', password: 'password' }
        expect(response.status).to eq(200)
        expect(response.header['access-token']).to be_present
      end
    end

    context 'signin to an existing user with wrong password' do
      it 'returns errors' do
        user = create(:user, email: 'zi@dinosys.com', password: 'password')
        user.confirm

        post '/api/v1/auth/sign_in', params: { email: 'zi@dinosys.com', password: 'password1234' }
        expect(response.status).to eq(401)
        expect(json_response[:errors]).to be_present
      end
    end

    describe 'signing out' do
      it 'works' do
        user = create(:user, email: 'zi@dinosys.com', password: 'password')
        auth_headers = user.create_new_auth_token

        delete '/api/v1/auth/sign_out', params: {}, headers: request_headers.merge(auth_headers)
        expect(response.status).to eq(200)
        expect(response.header['access-token']).to be_nil

        delete '/api/v1/auth/sign_out', params: {}, headers: request_headers.merge(auth_headers)
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'signing out' do
    it 'works' do
      user = create(:user, email: 'zi@dinosys.com', password: 'password')
      auth_headers = user.create_new_auth_token

      delete '/api/v1/auth/sign_out', params: {}, headers: request_headers.merge(auth_headers)

      expect(response.status).to eq(200)
      expect(response.header['access-token']).to be_nil

      delete '/api/v1/auth/sign_out', params: {}, headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(404)
    end
  end

  describe 'request password reset' do
    context 'when user provider is facebook' do
      it 'send email with provider facebook' do
        create(:user, provider: 'facebook', uid: '123243545', email: 'zi@dinosys.vn', facebook_uid: '123243545')
        post '/api/v1/auth/password', params: { email: 'zi@dinosys.vn',
                                                redirect_url: 'redirect_url' }.to_json, headers: request_headers

        expect(response.status).to eq(404)
      end
    end
    context 'when user exists' do
      let!(:user) { create(:user, email: 'zi@dinosys.com', password: 'password') }

      it 'works' do
        post '/api/v1/auth/password', params: { email: 'zi@dinosys.com', redirect_url: 'redirect_url' }.to_json,
                                      headers: request_headers
        expect(response.status).to eq(200)
      end

      it 'send reset password email' do
        mock_token = 'conmeomatreocaycau'
        expect(Devise).to receive(:friendly_token).and_return(mock_token)

        ActionMailer::Base.deliveries.clear

        post '/api/v1/auth/password', params: { email: 'zi@dinosys.com', redirect_url: 'redirect_url' }.to_json,
                                      headers: request_headers

        expect(response.status).to eq(200)
        expect(ActionMailer::Base.deliveries.size).to be(1)

        email = ActionMailer::Base.deliveries[0]
        expect(email.to).to include('zi@dinosys.com')
        expect(email.body).to match(mock_token)
      end
      it 'changes password' do
        post '/api/v1/auth/password', params: { email: 'zi@dinosys.com', redirect_url: 'redirect_url' }.to_json,
                                      headers: request_headers

        expect(response.status).to eq(200)
        expect(ActionMailer::Base.deliveries.size).to be(1)
        @mail = ActionMailer::Base.deliveries.last
        @mail_redirect_url = CGI.unescape(@mail.body.match(/redirect_url=([^&]*)&/)[1])
        @mail_reset_token = @mail.body.match(/reset_password_token=(.*)\"/)[1]

        get '/api/v1/auth/password/edit', params: { reset_password_token: @mail_reset_token,
                                                    redirect_url:  @mail_redirect_url },
                                          headers: request_headers

        returned_params = Rack::Utils.parse_query(URI.parse(response.location).query)
        returned_params['access-token'] = returned_params['token']
        returned_params['client'] = returned_params['client_id']
        put '/api/v1/auth/password', params: { password: 'abcd1234',
                                               password_confirmation: 'abcd1234' }.merge(returned_params).to_json,
                                     headers: request_headers
        expect(response.status).to eq(200)
        check_user = user.reload
        expect(check_user.valid_password?('abcd1234')).to eq(true)
      end
    end

    context 'when user not exist' do
      it 'work' do
        put '/api/v1/auth/password', params: { password: 'abcd1234',
                                               password_confirmation: 'abcd1234' }.to_json, headers: request_headers
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'signing in with Facebook' do
    let(:run_request) { post '/api/v1/auth/sign_in_with_facebook', params: { access_token: '434343243' }.to_json, headers: request_headers }
    let(:long_term_token) { '7587325357823583' }
    let(:facebook_uid) { '123243545' }

    before do
      mock_api = double(:mock_api, exchange_access_token_info: long_term_token)
      mock_graph_api = double(:mock_graph_api, get_object: profile)

      expect(Koala::Facebook::OAuth).to receive(:new).and_return mock_api
      expect(Koala::Facebook::API).to receive(:new).and_return mock_graph_api
    end

    context 'when profile does not contain email' do
      let(:profile) { { 'id' => facebook_uid } }

      it 'creates user without email' do
        create(:user, email: nil, password: 'password', provider: 'facebook', uid: '43423423532')

        expect { run_request }.to change(User, :count).by(1)
        expect(response.status).to eq(200)
        created_user = User.find_by_facebook_uid(facebook_uid)
        expect(created_user.provider).to eq('facebook')
        expect(created_user.uid).to eq(facebook_uid)
        expect(created_user.facebook_uid).to eq(facebook_uid)
        expect(created_user.facebook_credentials).to be_present
        expect(response.header['access-token']).to be_present
      end

      it 'logins user' do
        existing_user = create(:user, provider: 'facebook', uid: facebook_uid, email: nil, facebook_uid: facebook_uid)

        expect { run_request }.to_not change(User, :count)
        expect(response.status).to eq(200)

        returned_token = response.header['access-token']
        returned_client = response.header['client']
        expect(existing_user.reload.valid_token?(returned_token, returned_client)).to eq(true)
      end
    end

    context 'profile has email' do
      let(:profile) { { 'id' => facebook_uid, 'email' => 'zi@dinosys.vn' } }

      it 'creates user with email if user does not exist' do
        expect { run_request }.to change(User, :count).by(1)
        expect(response.status).to eq(200)

        created_user = User.find_by_email('zi@dinosys.vn')
        expect(created_user.provider).to eq('facebook')
        expect(created_user.uid).to eq(facebook_uid)
        expect(created_user.facebook_uid).to eq(facebook_uid)
        expect(created_user.facebook_credentials).to be_present
        expect(response.header['access-token']).to be_present
      end

      it 'saves to existing user if user already exists' do
        create(:user, email: 'zi@dinosys.vn', password: 'password')

        expect { run_request }.to_not change(User, :count)
        expect(response.status).to eq(200)

        existing_user = User.find_by_email('zi@dinosys.vn')
        expect(existing_user.provider).to eq('email')
        expect(existing_user.uid).to eq('zi@dinosys.vn')
        expect(existing_user.facebook_uid).to eq(facebook_uid)
        expect(existing_user.facebook_credentials).to be_present

        returned_token = response.header['access-token']
        returned_client = response.header['client']
        expect(existing_user.reload.valid_token?(returned_token, returned_client)).to eq(true)
      end
    end
  end
  describe 'updating user' do
    context 'updates address and name of user' do
      it 'returns token' do
        user = create(:user, email: 'zi@dinosys.com', password: 'password')
        auth_headers = user.create_new_auth_token
        put '/api/v1/auth', params: { address: 'Hanoi', name: 'HuanNguyen', phone_number: '01664152723' }.to_json,
                            headers: request_headers.merge(auth_headers)
        expect(response.status).to eq(200)
        user = user.reload
        expect(user.address).to eq('Hanoi')
        expect(user.name).to eq('HuanNguyen')
        expect(user.phone_number).to eq('01664152723')
      end
    end
  end
end
