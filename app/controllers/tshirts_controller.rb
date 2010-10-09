require 'ostruct'

class TshirtsController < ApplicationController

  before_filter :login_required

  def buy_tshirt
    @credit_card = new_card
  end

  def transparent_redirect_complete
    result = SpreedlyCore.purchase(params[:token], 5)
    # result = SpreedlyCore.authorize(params[:token], 5)
    puts result.body.yellow
    if result.code != 200
      establish_card_with_errors(result)
      set_flash_error(result)
      @payment_method_token = params[:token]
      return render(:action => :buy_tshirt)
    end

    redirect_to successful_purchase_url
  end

  def successful_purchase

  end


  private
    def set_flash_error(result)
      flash.now[:error] = result["transaction"]["response"]["message"]
    rescue Exception
    end

    def establish_card_with_errors(result)
      @credit_card = new_card(result["transaction"]["payment_method"])
      @credit_card.errors = validation_errors_from(result.body)
    end

    def new_card(attributes = {})
      defaults = { "first_name" => nil, "last_name" => nil, "number" => nil, "verification_value" => nil }

      # Temporary for making testing in the UI easier
      # defaults = { "first_name" => "Joe", "last_name" => "Smith", "number" => "4222222222222", "verification_value" => '232', "year" => 2013 }

      card = OpenStruct.new(defaults.merge(attributes))
      card.errors = ActiveModel::Errors.new(card)
      card.class.extend ActiveModel::Translation
      card
    end

    def validation_errors_from(body)
      errors = ActiveModel::Errors.new(@credit_card)

      doc = Hpricot(body)
      doc.search("transaction>payment_method>errors>error").each do |each|
        errors.add(each.attributes['attribute'], I18n.t(each.attributes['key']))
      end

      errors
    end

end
