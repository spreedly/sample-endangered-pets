class TshirtsController < ApplicationController
  TSHIRT_AMOUNT = 0.02

  def buy_tshirt
    @payment_method = PaymentMethod.new
  end

  def transparent_redirect_complete
    return if error_talking_to_core

    @payment_method = PaymentMethod.new(SpreedlyCore.get_payment_method(params[:token]))
    return render(action: :buy_tshirt) unless @payment_method.valid?

    response = SpreedlyCore.purchase(@payment_method, amount_to_charge, redirect_url: offsite_redirect_url, callback_url: offsite_callback_url)
    case response.code
    when 200
      return redirect_to(successful_purchase_url)
    when 202
      return redirect_to(Transaction.new(response).checkout_url)
    else
      set_flash_error(response)
      render(action: :buy_tshirt)
    end
  end

  def successful_purchase
  end

  def offsite_redirect
    return if error_talking_to_core

    @transaction = Transaction.new(SpreedlyCore.get_transaction(params[:transaction_token]))
    @payment_method = @transaction.payment_method
    case @transaction.state
    when "succeeded"
      redirect_to successful_purchase_url
    when "gateway_processing_failed"
      flash[:error] = @transaction.message
      render :buy_tshirt
    else
      raise "Unknown state #{@transaction.state}"
    end
  end

  def offsite_callback
    @@transactions_called_back ||= []
    @@transactions_called_back.concat(params[:transactions][:transaction].collect{|t| "#{t[:token]} for #{t[:amount]}: #{t[:message]} (#{t[:state]})"})
    head :ok
  end

  def history
    @transactions = (defined?(@@transactions_called_back) ? @@transactions_called_back : [])
  end

  private

  def set_flash_error(response)
    if response["errors"]
      flash.now[:error] = response["errors"]["error"]["__content__"]
    else
      flash.now[:error] = Transaction.new(response).message + " (#{transaction.state.humanize})"
    end
  end

  def error_talking_to_core
    return false if params[:error].blank?

    @payment_method = PaymentMethod.new
    flash.now[:error] = params[:error]
    render(action: :buy_tshirt)
    true
  end

  def amount_to_charge
    ((TSHIRT_AMOUNT * @payment_method.how_many.to_i) * 100).to_i
  end
end
