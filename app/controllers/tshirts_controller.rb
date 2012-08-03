class TshirtsController < ApplicationController
  def buy_tshirt
    @payment_method = PaymentMethod.new
  end

  def transparent_redirect_complete
    return if error_saving_card

    @payment_method = PaymentMethod.new(SpreedlyCore.get_payment_method(params[:token]))
    return render(action: :buy_tshirt) unless @payment_method.valid?

    response = SpreedlyCore.purchase(@payment_method, ((12.99 * @payment_method.how_many.to_i) * 100).to_i, redirect_url: successful_purchase_url, callback_url: callback_url)
    if(response.code == 200)
      if response["transaction"]["succeeded"]
        return redirect_to(successful_purchase_url)
      elsif response["transaction"]["pending"]
        return redirect_to(response["transaction"]["checkout_url"])
      end
    end

    set_flash_error(response)
    render(action: :buy_tshirt)
  end

  def callback
    @@transactions_called_back ||= []
    @@transactions_called_back.concat(params[:transactions][:transaction].collect{|t| "#{t[:token]} for #{t[:amount]}: #{t[:message]}"})
    head :ok
  end

  def history
    @transactions = (defined?(@@transactions_called_back) ? @@transactions_called_back : [])
  end

  private

  def set_flash_error(response)
    if response["errors"]
      error = response["errors"].values.first
      error = error["__content__"] if error["__content__"]
      flash.now[:error] = error
    elsif response['transaction']
      r = response['transaction']['response']
      flash.now[:error] = "#{r['message']} #{r['error_detail']}"
    else
      flash.now[:error] = "Exception from backend"
      @error = response.body
    end
  end

  def error_saving_card
    return false if params[:error].blank?

    @payment_method = PaymentMethod.new
    flash.now[:error] = params[:error]
    render(action: :buy_tshirt)
    true
  end
end
