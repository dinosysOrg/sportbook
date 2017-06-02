describe 'DevicesApi' do
  describe '#create' do
    let(:user) { create(:api_user) }
    let(:token) { SecureRandom.uuid }
    let(:platform) { 0 }
    let(:params) { { user_id: user.id, token: token, platform: platform } }
    let(:make_request) do
      auth_headers = user.create_new_auth_token
      post '/api/v1/devices/create', params: params.to_json,
                                     headers: request_headers.merge(auth_headers)
    end

    context 'when not signed in' do
      it 'store device token without login' do
        post '/api/v1/devices/create', params: params.to_json
        expect(response.status).to eq(401)
      end
    end

    context 'when signed in' do
      context 'with invalid data' do
        it 'user_id is blank' do
          params[:user_id] = nil
          expect(Device.count).to eq(0)
          make_request
          expect(response.status).to eq(422)
          expect(Device.count).to eq(0)
        end

        it 'token is blank' do
          params[:token] = nil
          expect(Device.count).to eq(0)
          make_request
          expect(response.status).to eq(422)
          expect(Device.count).to eq(0)
        end

        it 'platform is blank' do
          params[:platform] = nil
          expect(Device.count).to eq(0)
          make_request
          expect(response.status).to eq(422)
          expect(Device.count).to eq(0)
        end

        it 'platform is not valid' do
          params[:platform] = 2
          expect(Device.count).to eq(0)
          make_request
          expect(response.status).to eq(422)
          expect(Device.count).to eq(0)
        end
      end

      context 'with valid data' do
        it 'device token does not exist' do
          expect(Device.count).to eq(0)
          make_request
          expect(response.status).to eq(201)
          expect(Device.count).to eq(1)
        end

        it 'device token exists' do
          create(:device, user_id: user.id, token: token, platform: platform)
          expect(Device.count).to eq(1)
          make_request
          expect(response.status).to eq(422)
          expect(Device.count).to eq(1)
        end
      end
    end
  end
end
