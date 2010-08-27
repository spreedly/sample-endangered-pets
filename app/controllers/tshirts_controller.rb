
class TshirtsController < ApplicationController

  before_filter :login_required

  def buy_tshirt

  end

  def transparent_redirect_complete
    payment_method_token = params[:token]
    puts payment_method_token.inspect
  end

end
