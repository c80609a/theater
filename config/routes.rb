Rails.application.routes.draw do

  namespace :admin do
    resources :shows, only: [:index, :create, :destroy]
  end

  resources :shows, only: [:index]

end
