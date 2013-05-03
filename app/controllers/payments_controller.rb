module PaymentsController

  def offsite_callback
    @@transactions_called_back ||= []
    @@transactions_called_back.concat(params[:transactions][:transaction].collect{|t| "#{t[:token]} for #{t[:amount]}: #{t[:message]} (#{t[:state]})"})
    head :ok
  end

  def history
    @transactions = (defined?(@@transactions_called_back) ? @@transactions_called_back : [])
  end

  def set_flash_error(response)
    logger.fatal response.body
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
    render(action: render_action_for_error_talking_to_core)
    true
  end

end
