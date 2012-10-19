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
    return if error_talking_to_core

    @transaction = Transaction.new(SpreedlyCore.get_transaction(params[:transaction_token]))
    @payment_method = @transaction.payment_method
    case @transaction.state
    when "succeeded"
      redirect_to pets_successful_authorize_url
    when "processing"
      redirect_to pets_successful_delayed_authorize_url
    when "gateway_processing_failed"
      flash.now[:error] = @transaction.message
      render :buy
    else
      raise "Unknown state #{@transaction.state}"
    end
  end

  def offsite_callback
  end

  def successful_authorize
  end

  def successful_delayed_authorize
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

  def error_talking_to_core
    return false if params[:error].blank?

    @payment_method = PaymentMethod.new
    flash.now[:error] = params[:error]
    render(action: :buy)
    true
  end
end
