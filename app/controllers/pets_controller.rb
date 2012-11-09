class PetsController < ApplicationController

  include PaymentsController

  def subscribe

  end

  def transparent_redirect_complete
    @payment_method = PaymentMethod.new_from_core_response(SpreedlyCore.get_payment_method(params[:token]))
    @payment_method.recurring = true

    response = SpreedlyCore.authorize(@payment_method, amount_to_authorize, redirect_url: pets_offsite_authorize_redirect_url, callback_url: pets_offsite_callback_url)
    return render(action: :subscribe) unless @payment_method.save

    case response.code
    when 202
      return redirect_to(Transaction.new(response).checkout_url)
    else
      set_flash_error(response)
      render(action: :subscribe)
    end
  end

  def initiate_charge
    @payment_method = PaymentMethod.find_by_token!(params[:token])
    response = SpreedlyCore.purchase(@payment_method, amount_to_charge)

    case response.code
    when 202
      return redirect_to admin_url, notice: "Charge successful.  The funds will be transferred soon."
    else
      set_flash_error(response)
      render(template: 'admin/index')
    end

  end

  def offsite_authorize_redirect
    return if error_talking_to_core

    @transaction = Transaction.new(SpreedlyCore.get_transaction(params[:transaction_token]))
    @payment_method = @transaction.payment_method
    case @transaction.state
    when "processing"
      redirect_to pets_successful_delayed_authorize_url
    when "gateway_processing_failed"
      flash.now[:error] = @transaction.message
      render :buy
    else
      raise "Unknown state #{@transaction.state}"
    end
  end

  def successful_delayed_authorize
  end

  def successful_delayed_purchase
  end


  private
  def amount_to_authorize
    139 * 100
  end

  def amount_to_charge
    50 * 100
  end
end
