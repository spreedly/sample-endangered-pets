class PaymentMethod < ActiveRecord::Base
  attr_accessor :how_many, :recurring
  attr_writer   :credit_card

  validates_presence_of :how_many, unless: :recurring
  validates_presence_of :email, if: :recurring
  validates_numericality_of :how_many, only_integer: true, allow_nil: true
  validate :credit_card_is_valid, if: :is_credit_card?

  def self.each(current=nil)
    methods = SpreedlyCore.config["payment_methods"].keys
    methods.unshift(methods.delete("credit_card"))
    methods.unshift(methods.delete(current))
    methods.compact!
    methods.each do |m|
      yield(m)
    end
  end

  def self.new_from_core_response(response)
    payment_method = PaymentMethod.new
    payment_method.credit_card = CreditCard.new(response)

    attributes = response["payment_method"]
    payment_method.token = attributes["token"]
    payment_method.payment_method_type = attributes["payment_method_type"]
    payment_method.how_many = attributes["data"].try(:[], "how_many")
    payment_method.email = attributes["data"].try(:[], "email")
    payment_method
  end

  def is_credit_card?
    (payment_method_type.blank? || (payment_method_type == "credit_card"))
  end

  def credit_card_is_valid
    errors.add(:base, "Invalid credit card") unless credit_card.valid?
  end

  def credit_card
    @credit_card ||= CreditCard.new
  end
end
