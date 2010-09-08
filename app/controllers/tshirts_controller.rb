require 'ostruct'

class TshirtsController < ApplicationController

  before_filter :login_required

  def buy_tshirt
    @credit_card = new_card
  end

  def transparent_redirect_complete
    result = SpreedlyCore.purchase(params[:token], "2")
    if result.code == 422
      @credit_card = new_card(result["transaction"]["payment_method"])
      return render(:action => :buy_tshirt) 
    end

    redirect_to buy_tshirt_url
  end


  private
    def new_card(attributes = {})
      defaults = { "first_name" => nil, "last_name" => nil, "number" => nil, "verification_value" => nil }
      OpenStruct.new(defaults.merge(attributes))
    end

end
