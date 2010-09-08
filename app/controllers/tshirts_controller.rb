require 'ostruct'
# require 'hpricot'

class TshirtsController < ApplicationController

  before_filter :login_required

  def buy_tshirt
    @credit_card = new_card
  end

  def transparent_redirect_complete
    result = SpreedlyCore.purchase(params[:token], "2")
    if result.code == 422
      @credit_card = new_card(result["transaction"]["payment_method"])
      errors = ActiveModel::Errors.new(@credit_card)

      doc = Hpricot(result.body)
      doc.search("transaction>payment_method>errors>error").each do |each|
        errors.add(each.attributes['attribute'], I18n.t(each.attributes['key']))
      end

      @credit_card.errors = errors
      return render(:action => :buy_tshirt) 
    end

    redirect_to buy_tshirt_url
  end


  private
    def new_card(attributes = {})
      defaults = { "first_name" => nil, "last_name" => nil, "number" => nil, "verification_value" => nil }
      card = OpenStruct.new(defaults.merge(attributes))
      card.errors = ActiveModel::Errors.new(card) 
      card.class.extend ActiveModel::Translation
      card
    end

end
