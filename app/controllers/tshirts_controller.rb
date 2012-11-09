class TshirtsController < ApplicationController
  include PaymentsController

  TSHIRT_AMOUNT = 0.02

  def buy
    @payment_method = PaymentMethod.new
  end

  def tshirt_club
    @payment_method = PaymentMethod.new
  end

  def transparent_redirect_complete
    return if error_talking_to_core

    @payment_method = PaymentMethod.new_from_core_response(SpreedlyCore.get_payment_method(params[:token]))
    return render(action: :buy) unless @payment_method.valid?

    response = SpreedlyCore.purchase(@payment_method, amount_to_charge, redirect_url: tshirts_offsite_redirect_url, callback_url: tshirts_offsite_callback_url)
    case response.code
    when 200
      return redirect_to(tshirts_successful_purchase_url)
    when 202
      return redirect_to(Transaction.new(response).checkout_url)
    else
      set_flash_error(response)
      render(action: :buy)
    end
  end

  def successful_purchase
  end

  def successful_delayed_purchase
  end

  def offsite_redirect
    return if error_talking_to_core

    @transaction = Transaction.new(SpreedlyCore.get_transaction(params[:transaction_token]))
    @payment_method = @transaction.payment_method
    case @transaction.state
    when "succeeded"
      redirect_to tshirts_successful_purchase_url
    when "processing"
      redirect_to tshirts_successful_delayed_purchase_url
    when "gateway_processing_failed"
      flash.now[:error] = @transaction.message
      render :buy
    else
      raise "Unknown state #{@transaction.state}"
    end
  end

  private
  def amount_to_charge
    ((TSHIRT_AMOUNT * @payment_method.how_many.to_i) * 100).to_i
  end
end
