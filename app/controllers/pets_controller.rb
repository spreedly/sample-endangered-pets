class PetsController < ApplicationController

  include PaymentsController

  def subscribe

  end

  def transparent_redirect_complete
    @payment_method = PaymentMethod.new_from_core_response(SpreedlyCore.get_payment_method(params[:token]))
    @payment_method.recurring = true

    response = SpreedlyCore.authorize(@payment_method, amount_to_authorize, redirect_url: pets_offsite_authorize_redirect_url,
                                      callback_url: pets_offsite_callback_url, description: "Endangered Pet Subscription",
                                      retain_on_success: true)

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
    when 202, 200
      transaction = Transaction.new(response)
      message = "Charge successful."
      message += "  The funds will be transferred soon." if transaction.state == "processing"
      return redirect_to admin_url, notice: message
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
    when "processing", "succeeded"
      redirect_to pets_successful_delayed_authorize_url
    when "gateway_processing_failed"
      flash.now[:error] = @transaction.message
      render :subscribe
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
    109
  end

  def amount_to_charge
    3
  end

  def render_action_for_error_talking_to_core
    :subscribe
  end

end
