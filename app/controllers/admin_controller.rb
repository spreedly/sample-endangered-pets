class AdminController < ApplicationController

  def index
    @payment_methods = PaymentMethod.recurring.order('created_at DESC')
  end

end
