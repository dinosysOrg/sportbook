describe Admin::DashboardController, type: :controller do
  describe 'Access to /admin' do
    context 'logged in' do
      before do
        @admin_user = create :admin_user
      end

      it 'user has admin role' do
        sign_in @admin_user
        get :index
        assert_response :success
      end

      it 'user has more than 2 roles include Admin' do
        user_role = Role.create(name: 'User')
        create(:roles_user, user: @admin_user, role: user_role)

        sign_in @admin_user
        get :index
        assert_response :success
      end
    end

    context 'not logged in' do
      before do
        @user = create :admin_user
        @user.roles.destroy_all
      end

      it 'user does not have role' do
        sign_in @user
        get :index
        assert_response :redirect
        expect(response).to redirect_to new_admin_user_session_path
      end

      it 'user has more roles without admin role' do
        user_role = Role.create(name: 'User')
        create(:roles_user, user: @user, role: user_role)

        sign_in @user
        get :index
        assert_response :redirect
        expect(response).to redirect_to new_admin_user_session_path
      end
    end
  end
end
