CoreSample::Application.routes.draw do

  match 'buy_tshirt' => 'tshirts#buy_tshirt'
  match 'transparent_redirect_complete' => 'tshirts#transparent_redirect_complete'
  match 'successful_purchase' => 'tshirts#successful_purchase'

  root :to => "home#index"

end
