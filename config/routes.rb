Rails.application.routes.draw do
  namespace :api do
  get 'base/authenticate'
  end

  namespace :api do
  get 'base/permission_denied'
  end

  devise_for :users

  resources :task_lists, only: [:show]

  namespace :api, defaults: { format: :json } do
    resources :task_lists, only: [:index] do
      resources :tasks, only: [:index, :create, :update, :destroy]
    end
  end

  root 'home#index'
end
