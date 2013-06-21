module PaymentsController

  def offsite_callback
    transactions = Array.wrap(params[:transactions][:transaction]).collect do |each|
      transaction = Transaction.new({ 'transaction' => each })
      payment_method = transaction.payment_method
      payment_method.save! if payment_method.recurring && transaction.processing_or_succeeded?
      transaction.update_order
    end
    head :ok
  end

  def set_flash_error(response)
    if response["errors"]
      details = response["errors"]["error"]
      if details.kind_of? Array
        flash.now[:error] = details.map { |e| e["__content__"] }
      else
        flash.now[:error] = details["__content__"]
      end
    else
      t = Transaction.new(response)
      flash.now[:error] =  "#{t.message} (#{t.state.humanize})"
    end
  end

  def error_talking_to_core
    return false if params[:error].blank?

    @payment_method = PaymentMethod.new
    flash.now[:error] = params[:error]
    render(action: render_action_for_error_talking_to_core)
    true
  end

end
