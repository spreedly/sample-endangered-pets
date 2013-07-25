class PetClubController < ApplicationController

  include PaymentsController

  def subscribe

  end

  def transparent_redirect_complete
    return if error_talking_to_core

    @payment_method = PaymentMethod.new_from_core_response(SpreedlyCore.get_payment_method(params[:token]))
    @payment_method.recurring = true

    return render(action: :subscribe) unless @payment_method.valid?

    response = SpreedlyCore.authorize(@payment_method, amount_to_authorize, redirect_url: pet_club_offsite_authorize_redirect_url,
                                      callback_url: pet_club_offsite_callback_url, description: "Endangered Pet Subscription",
                                      retain_on_success: true)

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

    order = Order.create_pet_club_charge_order!(@payment_method)
    response = SpreedlyCore.purchase(@payment_method, order.amount, callback_url: pet_club_offsite_callback_url, order_id: order.id)
    order.update_from(response)

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
      @payment_method.save!
      redirect_to pet_club_successful_delayed_authorize_url
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

  def render_action_for_error_talking_to_core
    :subscribe
  end

end
