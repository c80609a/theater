Rails.application.routes.draw do

  resources :shows, only: [:index, :create, :destroy]

end
