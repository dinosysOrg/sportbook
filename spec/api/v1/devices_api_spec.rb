describe 'DevicesApi' do
  describe '#create' do
    let(:user) { create(:api_user) }
    let(:token) { SecureRandom.uuid }
    let(:udid) { SecureRandom.hex(8) }
    let(:platform) { 0 }
    let(:params) { { user_id: user.id, token: token, platform: platform, udid: udid } }
    let(:auth_headers) { user.create_new_auth_token }
    let(:make_request) do
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
        it 'udid is blank' do
          params[:udid] = nil
          expect(Device.count).to eq(0)
          expect { make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
        end

        it 'token is blank' do
          params[:token] = nil
          expect(Device.count).to eq(0)
          expect { make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
        end

        it 'platform is blank' do
          params[:platform] = nil
          expect(Device.count).to eq(0)
          expect { make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
        end

        it 'platform is not valid' do
          params[:platform] = 2
          expect(Device.count).to eq(0)
          expect { make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
        end

        it 'without locale' do
          params[:udid] = nil
          expect(Device.count).to eq(0)
          expect { make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
          expect(json_response[:errors].first[:attribute]).to eq 'udid'
          expect(json_response[:errors].first[:message]).to include "can't be blank"
        end

        it 'with locale = vi' do
          params[:udid] = nil
          expect(Device.count).to eq(0)
          other_make_request = post '/api/v1/devices/create?locale=vi', params: params.to_json,
                                                                        headers: request_headers.merge(auth_headers)
          expect { other_make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
          expect(json_response[:errors].first[:attribute]).to eq 'udid'
          expect(json_response[:errors].first[:message]).to include 'không thể để trắng'
        end
      end

      context 'with valid data' do
        it 'device token does not exist' do
          expect(Device.count).to eq(0)
          expect { make_request }.to change(Device, :count).from(0).to(1)
          expect(response.status).to eq(201)
        end

        it 'device token exists' do
          create(:device, user_id: user.id, token: token, platform: platform)
          expect(Device.count).to eq(1)
          expect { make_request }.to_not change(Device, :count)
          expect(response.status).to eq(422)
          expect(json_response[:errors]).to be_present
        end

        it 'device id does not exists' do
          expect { make_request }.to change(Device, :count).from(0).to(1)
          expect(response.status).to eq 201
        end

        it 'device id exists' do
          create(:device, user_id: user.id, udid: udid)
          expect { make_request }.to_not change(Device, :count)
        end
      end
    end
  end

  describe '#delete' do
    let(:user) { create(:api_user) }
    let(:udid) { SecureRandom.hex(8) }
    let!(:device) { create(:device, user_id: user.id, udid: udid) }
    let(:auth_headers) { user.create_new_auth_token }

    it 'remove user_id after log out' do
      params = { udid: udid }
      put '/api/v1/devices/delete', params: params.to_json,
                                    headers: request_headers.merge(auth_headers)

      expect(response.status).to eq 200
      device.reload
      expect(device.user_id).to be_nil
    end

    it 'udid not exists' do
      params = { udid: SecureRandom.hex(8) }
      put '/api/v1/devices/delete', params: params.to_json,
                                    headers: request_headers.merge(auth_headers)
      expect(response.status).to eq 200
      expect(json_response).to be_nil
    end
  end
end
