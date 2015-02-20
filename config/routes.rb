Rails.application.routes.draw do
  #get 'map_display/index'

  #get 'home/index'

  root to: 'visitors#index'

  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  resources :users

  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  # resources :users do
  #   get 'invite', :on => :member
  # end

  # get "home/fetch_friend_data"

end
