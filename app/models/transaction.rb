class Transaction
  include ActiveModel::Validations
  include ActiveModel::Conversion

  def initialize(core_response=nil)
    initialize_attributes(core_response["transaction"]) if core_response
  end

  def initialize_attributes(attributes={})
  end

end
