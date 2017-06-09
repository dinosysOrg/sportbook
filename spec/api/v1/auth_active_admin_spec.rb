describe 'Auth active admin' do
  describe 'signing up' do
    it 'add uid' do
      post '/admin', params: { admin_user: { email: 'abc@gmail.com', password: '123456789', password_confirmation: '123456789' } }
      expect(response.status).to eq(302)
      user = User.find_by(email: 'abc@gmail.com')
      expect(user.valid_password?('123456789')).to be true
      expect(user.uid).to eq('abc@gmail.com')
    end
  end
end
