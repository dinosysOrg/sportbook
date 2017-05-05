Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount ApplicationApi => '/'

  resources :tournaments, only: [] do
    resources :matches, only: [:index]
    resources :players, only: [:index]
    resources :groups, only: [:index]
  end

  namespace :api do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
    end
  end
end