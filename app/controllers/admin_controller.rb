class AdminController < ApplicationController

  def index
  end

  def initiate_charge
    payment_method = PaymentMethod.find_by_token!(params[:token])
    d { payment_method }
    redirect_to admin_url
  end

end
