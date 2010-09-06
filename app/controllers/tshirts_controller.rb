
class TshirtsController < ApplicationController

  before_filter :login_required

  def buy_tshirt

  end

  def transparent_redirect_complete
    payment_method_token = params[:token]
    @result = SpreedlyCore.purchase(payment_method_token, "2")
    puts @result.code.to_s.magenta
    puts @result.body.yellow
    # return render(:action => :buy_tshirt) if @result.code.to_s == "422"
    redirect_to buy_tshirt_url
  end

end
