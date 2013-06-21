class TshirtsController < ApplicationController
  include PaymentsController

  def buy
    @payment_method = PaymentMethod.new
    @paying_with_credit_card = false
  end

  def transparent_redirect_complete
    return if error_talking_to_core

    @payment_method = PaymentMethod.new_from_core_response(SpreedlyCore.get_payment_method(params[:token]))
    @paying_with_credit_card = @payment_method.payment_method_type == 'credit_card'
    return render(action: :buy) unless @payment_method.valid?

    order = Order.create_tshirt_order!(@payment_method)
    response = SpreedlyCore.purchase(@payment_method, order.amount, order_id: order.id, redirect_url: tshirts_offsite_redirect_url, callback_url: tshirts_offsite_callback_url)
    order.update_from(response)

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
    @transaction.update_order
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
  def render_action_for_error_talking_to_core
    :buy
  end
end
