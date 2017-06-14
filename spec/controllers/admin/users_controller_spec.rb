describe Admin::UsersController, type: :controller do
  describe 'create user in admin page' do
    before do
      @admin_user = create :admin_user
    end

    it 'work' do
      sign_in @admin_user
      post :create, user: { name: 'test_name', email: 'test@gmail.com', password: '123456789', password_confirmation: '123456789' }
      expect(User.second.uid).to eq('test@gmail.com')
    end
  end
end
