class IndexPaymentMethodToken < ActiveRecord::Migration
  def change
    add_index :payment_methods, :token
  end

end
