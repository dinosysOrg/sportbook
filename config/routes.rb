Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount ApplicationApi => '/'

  resources :tournaments, only: [:show] do
    resources :matches, only: [:index]
    resources :players, only: [:index]
    resources :groups, only: [:index]
  end

  get 'api/v1/matches', to: 'matches#index'

  post 'api/v1/auth/sign_in_with_facebook', to: 'auth_api#create'
  mount_devise_token_auth_for 'ApiUser', at: 'api/v1/auth', controllers: { passwords: 'passwords' }

  root 'home#home'
end
