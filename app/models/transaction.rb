class Transaction
  attr_reader :state, :message, :payment_method, :checkout_url, :reference

  def initialize(core_response=nil)
    initialize_attributes(core_response["transaction"]) if core_response
    @payment_method = PaymentMethod.new_from_core_response(core_response["transaction"])
  end

  def initialize_attributes(attributes={})
    @state = attributes["state"]
    @checkout_url = attributes["checkout_url"]
    @reference = attributes["reference"]
    if @state == "gateway_setup_failed"
      @message = attributes["setup_response"]["message"]
    else
      @message = (attributes["message"]["__content__"] || attributes["message"])
    end
  end
end
