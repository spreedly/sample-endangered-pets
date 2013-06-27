class OrdersController < ApplicationController

  include PaymentsController

  before_filter :initialize_orders

  def index
  end

  def settle
    response = SpreedlyCore.settle_test_gateway_transactions(params[:state])
    if response.code != 200
      set_flash_error(response)
      return render :index
    else
      flash[:notice] = "Notified the test gateway to settle the transactions.  Refresh this page to see the updated transactions."
    end

    redirect_to orders_url
  end


  private
  def initialize_orders
    @orders = Order.order('created_at DESC')
  end
end
