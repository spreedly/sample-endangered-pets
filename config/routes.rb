CoreSample::Application.routes.draw do
  scope(path: "tshirts", controller: :tshirts, as: :tshirts) do
    match :buy
    get :transparent_redirect_complete
    get :successful_purchase
    get :successful_delayed_purchase
    get :offsite_redirect
    get :offsite_callback, format: :xml
    get :history
  end

  scope(path: "pets", controller: :pets, as: :pets) do
    match :subscribe
    get :transparent_redirect_complete
    get :successful_authorize
    get :successful_delayed_authorize
    get :offsite_redirect
    get :offsite_callback, format: :xml
    put :initiate_charge
  end

  root to: "home#index"
end
