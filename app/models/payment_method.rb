class PaymentMethod
  include ActiveModel::Validations

  attr_accessor :credit_card, :how_many, :type, :token

  validates_presence_of :how_many
  validates_numericality_of :how_many, only_integer: true, allow_nil: true
  validate :credit_card_is_valid, if: :is_credit_card?

  def self.each(current=nil)
    methods = SpreedlyCore.config["payment_methods"].keys
    methods.unshift(methods.delete("CreditCard"))
    methods.unshift(methods.delete(current))
    methods.compact!
    methods.each do |m|
      yield(m)
    end
  end

  def initialize(core_response=nil)
    @credit_card = CreditCard.new(core_response)
    initialize_attributes(core_response["payment_method"]) if core_response
  end

  def initialize_attributes(attributes={})
    attributes ||= {}
    self.token = attributes["token"]
    self.type = attributes["payment_method_type"]
    self.how_many = attributes["data"].try(:[], "how_many")
  end

  def is_credit_card?
    (type.blank? || (type == "CreditCard"))
  end

  def credit_card_is_valid
    errors.add(:base, "Invalid credit card") unless credit_card.valid?
  end
end
