CoreSample::Application.routes.draw do
  scope(path: "tshirts", controller: :tshirts, as: :tshirts) do
    match :buy
    get :transparent_redirect_complete
    get :successful_purchase
    get :successful_delayed_purchase
    get :offsite_redirect
    post :offsite_callback
  end

  scope(path: "pets", controller: :pets, as: :pets) do
    match :subscribe
    get :transparent_redirect_complete
    get :successful_delayed_authorize
    get :successful_delayed_purchase
    get :offsite_authorize_redirect
    post :offsite_callback
  end

  get  'admin' => 'admin#index'
  post 'admin/payment_methods/:token/initate_charge' => 'pets#initiate_charge', as: :initiate_charge
  resources :orders, only: [ :index ] do
    collection do
      post :settle
    end
  end

  get 'about' => "home#about"
  root to: "home#index"
end
