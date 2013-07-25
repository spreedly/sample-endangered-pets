class Order < ActiveRecord::Base

  TSHIRT_PRICE = 0.02
  belongs_to :payment_method

  def self.create_pets_order!(payment_method)
    order = Order.new(order_type: :pet)
    order.payment_method = payment_method
    order.quantity = payment_method.how_many
    order.amount = ((TSHIRT_PRICE * payment_method.how_many.to_i) * 100).to_i
    order.save!
    order
  end

  def self.create_pet_club_charge_order!(payment_method)
    order = Order.new(order_type: :pet_club_charge)
    order.payment_method = payment_method
    order.email = payment_method.email
    order.amount = 3
    order.save!
    order
  end

  def update_from(response)
    self.update_attribute(:state, Transaction.new(response).state)
  end

end
