class Transaction
  attr_reader :state, :message, :payment_method

  def initialize(core_response=nil)
    initialize_attributes(core_response["transaction"]) if core_response
    @payment_method = PaymentMethod.new(core_response["transaction"])
  end

  def initialize_attributes(attributes={})
    @state = attributes["state"]
    @message = attributes["message"]["__content__"]
  end
end
