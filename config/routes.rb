CoreSample::Application.routes.draw do

  match 'login' => 'sessions#new'
  match 'logout' => 'sessions#destroy'
  match 'signup' => 'users#new'
  
  resources :users
  resources :sessions

  root :to => "home#index"

end
