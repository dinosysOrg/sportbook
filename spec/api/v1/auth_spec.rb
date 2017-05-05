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
    context 'when user exists' do
      before { create(:user, email: 'zi@dinosys.com', password: 'password') }

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
    end
  end
end
