class OrdersController < ApplicationController

  def index
    @orders = Order.order('created_at DESC')

  end

end
