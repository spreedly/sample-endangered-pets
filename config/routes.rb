CoreSample::Application.routes.draw do
  match "buy_tshirt" => "tshirts#buy_tshirt"
  match "transparent_redirect_complete" => "tshirts#transparent_redirect_complete"
  match "successful_purchase" => "tshirts#successful_purchase"
  match "offsite_redirect" => "tshirts#offsite_redirect"
  match "offsite_callback" => "tshirts#offsite_callback", format: :xml
  match "history" => "tshirts#history"

  root to: "home#index"
end
