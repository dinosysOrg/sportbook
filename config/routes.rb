Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount ApplicationApi => '/'

  resources :tournaments, only: [] do
    resources :matches, only: [:index]
    resources :players, only: [:index]
    resources :groups, only: [:index]
  end

  namespace :api do
    scope :v1 do
      post 'auth/sign_in_with_facebook', to: '/auth_api#create'
      mount_devise_token_auth_for 'ApiUser', at: 'auth', controllers: { passwords: 'passwords' }
    end
  end
end
