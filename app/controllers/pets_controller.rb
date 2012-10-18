class PetsController < ApplicationController

  def subscribe

  end

  def transparent_redirect_complete
    @payment_method = PaymentMethod.new(SpreedlyCore.get_payment_method(params[:token]))

    response = SpreedlyCore.authorize(@payment_method, amount_to_charge, redirect_url: pets_offsite_redirect_url, callback_url: pets_offsite_callback_url)
    d { response.code }
    d { response.body }
    case response.code
    when 200
      return redirect_to(pets_successful_purchase_url)
    when 202
      return redirect_to(Transaction.new(response).checkout_url)
    else
      set_flash_error(response)
      render(action: :subscribe)
    end
  end

  def offsite_redirect
  end

  def offsite_callback
  end


  private
  def amount_to_charge
    139 * 100
  end

  def set_flash_error(response)
    if response["errors"]
      flash.now[:error] = response["errors"]["error"]["__content__"]
    else
      t = Transaction.new(response)
      flash.now[:error] =  "#{t.message} (#{t.state.humanize})"
    end
  end
end
